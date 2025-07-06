local M2Click = {
    hScaleFactor = 1.5,
    vScaleFactor = 1.5
}
local CameraUtils = require(script.Parent.CameraUtils)
local PlayerUtils = require(script.Parent.PlayerUtils)
local RaycastUtils = require(script.Parent.RaycastUtils)
local DotUtils = require(script.Parent.DotUtils)
local LaserUtils = require(script.Parent.LaserUtils)

local PlaceDotEvent = game:GetService("ReplicatedStorage").Events.PlaceDot

function M2Click.ScaledStepSize(renderDistance, camera, viewportSize, raycastParams)
     local ray1 = camera:ViewportPointToRay(0, 0)
    local ray2 = camera:ViewportPointToRay(viewportSize.X, 0)
    local ray3 = camera:ViewportPointToRay(0, viewportSize.Y)

	local res1 = RaycastUtils.SendRaycast(ray1.Origin, ray1.Direction.Unit * renderDistance, raycastParams)
    local res2 = RaycastUtils.SendRaycast(ray2.Origin, ray2.Direction.Unit * renderDistance, raycastParams)
    local res3 = RaycastUtils.SendRaycast(ray3.Origin, ray3.Direction.Unit * renderDistance, raycastParams)

	local count = 1
	if res1 == nil then
		while res1 == nil do
			ray1 = camera:ViewportPointToRay(0 + count, 0 + count)
			res1 = RaycastUtils.SendRaycast(ray1.Origin, ray1.Direction.Unit * renderDistance, raycastParams)
			count += 1
			if count > 1000 then
				print("Failed to get a valid raycast after 1000 attempts")
				return nil
			end
		end
	elseif res2 == nil then
		while res2 == nil do
			ray2 = camera:ViewportPointToRay(viewportSize.X - count, 0)
			res2 = RaycastUtils.SendRaycast(ray2.Origin, ray2.Direction.Unit * renderDistance, raycastParams)
			count += 1
			if count > 1000 then
				print("Failed to get a valid raycast after 1000 attempts")
				return nil
			end
		end
	end
	if res1 and res2 and res3 then
		local hdist = (res2.Position - res1.Position).Magnitude * M2Click.hScaleFactor
		local vdist = (res3.Position - res1.Position).Magnitude * M2Click.vScaleFactor
		return Vector2.new(viewportSize.X / hdist, viewportSize.Y / vdist)
	end
	
	return nil
end

function M2Click.Click(scanner)
    local cam = game.Workspace.CurrentCamera
    if not scanner.scanning and not scanner.m2Cooldown then
        if scanner.scannable then
            scanner:SetScannable(false)
            scanner:SetScanning(true)

            CameraUtils.ToggleLockCamera()
            PlayerUtils.ToggleLockPlayer()

            local viewportSize = cam.ViewportSize

            local xVal = 0
            local yVal = 0

            local stepSizeVector = M2Click.ScaledStepSize(scanner.renderDistance, cam, viewportSize, scanner.raycastParams)
            
            if stepSizeVector then
                local lastPos = Vector3.new(9e999, 9e999, 9e999)
                while (yVal + stepSizeVector.Y) < viewportSize.Y do
                    while (xVal + stepSizeVector.X) < viewportSize.X do
                        local ray = cam:ViewportPointToRay(xVal, yVal)
                        local randomRay = DotUtils.RandomizeAndFormatDirectionVector(ray.Direction.Unit, scanner)
                        local raycastResult = RaycastUtils.SendRaycast(ray.Origin, randomRay, scanner.raycastParams)
                        if raycastResult ~= nil then
                            if (lastPos - raycastResult.Position).Magnitude >= 1.5 then
                                local laserCor = coroutine.create(LaserUtils.DrawLaser)
                                coroutine.resume(laserCor, raycastResult, scanner.scannerToolRef)
                                PlaceDotEvent:FireServer(raycastResult.Position, raycastResult.Normal, raycastResult.Instance:GetAttribute("objectType"))
                                lastPos = raycastResult.Position
                                if not scanner.m2Cooldown then
                                    scanner:SetM2Cooldown(true)
                                    scanner.scannerToolRef.Scanner.TopScreen.BrickColor = BrickColor.new("Bright red")
                                end
                            end
                        end
                        xVal += stepSizeVector.X
                    end
                    task.wait()
                    xVal = 0
                    yVal += stepSizeVector.Y
                end
            end
            scanner:SetScanning(false)
            scanner:SetScannable(true)

            CameraUtils.ToggleLockCamera()
            PlayerUtils.ToggleLockPlayer()
            task.wait(7)

            scanner:SetM2Cooldown(false)
            scanner.scannerToolRef.Scanner.TopScreen.BrickColor = BrickColor.new("Bright blue")
        end
    end
end

return M2Click
