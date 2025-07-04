local M2Scan = {}
print("M2Scan module loaded")
local ScannerManager = require(script.Parent.ScannerManager)
local PlayerUtils = require(script.Parent.PlayerUtils)
local RaycastController = require(script.Parent.RaycastController)
local LaserDrawer = require(script.Parent.LaserDrawer)
local RS = game:GetService("ReplicatedStorage")
local PlaceDot = RS.Events.PlaceDot

local plr = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera

function M2Scan:ScaledStepSize(viewportSize)
	local ray1 = camera:ViewportPointToRay(0, 0)
	local ray2 = camera:ViewportPointToRay(viewportSize.X, 0)
	local ray3 = camera:ViewportPointToRay(0, viewportSize.Y)
	local res1 = RaycastController:SendRaycast(ray1.Origin, ray1.Direction.Unit * ScannerManager.renderDistance)
	local res2 = RaycastController:SendRaycast(ray2.Origin, ray2.Direction.Unit * ScannerManager.renderDistance)
	local res3 = RaycastController:SendRaycast(ray3.Origin, ray3.Direction.Unit * ScannerManager.renderDistance)
	print("res1:", res1)
	print("res2:", res2)
	print("res3:", res3)
	if res1 and res2 and res3 then
		local hdist = (res2.Position - res1.Position).Magnitude * ScannerManager.hScaleFactor
		local vdist = (res3.Position - res1.Position).Magnitude * ScannerManager.vScaleFactor
		return Vector2.new(viewportSize.X / hdist, viewportSize.Y / vdist)
	end
	local count = 1
	while res2 == nil or res3 == nil do
		ray1 = camera:ViewportPointToRay(0 + count, 0 + count)
		ray2 = camera:ViewportPointToRay(viewportSize.X - count, 0)

		res1 = RaycastController:SendRaycast(ray1.Origin, ray1.Direction.Unit * ScannerManager.renderDistance)
		res2 = RaycastController:SendRaycast(ray2.Origin, ray2.Direction.Unit * ScannerManager.renderDistance)

		count += 1
		if count > 1000 then
			print("Failed to get valid rays after 100 attempts")
			return nil
		end
	end
	print("res1:", res1)
	print("res2:", res2)
	local hdist = (res2.Position - res1.Position).Magnitude * ScannerManager.hScaleFactor
	local vdist = (res3.Position - res1.Position).Magnitude * ScannerManager.vScaleFactor
	return Vector2.new(viewportSize.X / hdist, viewportSize.Y / vdist)
	-- return nil
end

function M2Scan:Scan()
	if ScannerManager.scannable and not ScannerManager.m2Cooldown and not ScannerManager.scanning then
		ScannerManager.scannable = false
		ScannerManager.scanning = true

		PlayerUtils:ToggleLockCamera()
		PlayerUtils:ToggleLockPlayer()

		local viewportSize = camera.ViewportSize
		local stepSizeVector = M2Scan:ScaledStepSize(viewportSize)
		print("Step Size Vector:", stepSizeVector)
		local xVal = 0
		local yVal = 0

		if stepSizeVector then
			local lastposition = Vector3.new(9e999, 9e999, 9e999)
			while (yVal + stepSizeVector.Y) < viewportSize.Y do
				while (xVal + stepSizeVector.X) < viewportSize.X do
					local ray = camera:ViewportPointToRay(xVal, yVal)
					local randomRay = ScannerManager:RandomizeDirection(ray.Direction.Unit)
					local raycastResult = RaycastController:SendRaycast(ray.Origin, randomRay)
					if raycastResult ~= nil then
						if (lastposition - raycastResult.Position).Magnitude >= 2.5 then
							-- local laserCor = coroutine.create(LaserDrawer.DrawLaser)
							-- coroutine.resume(laserCor, raycastResult)
							PlaceDot:FireServer(
								raycastResult.Position,
								raycastResult.Normal,
								raycastResult.Instance:GetAttribute("objectType")
							)
							lastposition = raycastResult.Position
							if not ScannerManager.m2Cooldown then
								ScannerManager.m2Cooldown = true
								plr.Character.Scanner.Scanner.TopScreen.BrickColor = BrickColor.new("Bright red")
							end
						end
						--*** DIFF METHOD FOR DISTANCE BETWEEN DOTS
						--if (lastposition - raycastResult.Position).Magnitude <= .7 then
						--	xVal += stepSizeVector.X * 2
						--	continue
						--end
						--PlaceDot:FireServer(raycastResult.Position, raycastResult.Normal)
						--lastposition = raycastResult.Position
						--***
					end
					xVal += stepSizeVector.X
				end
				task.wait()
				xVal = 0
				yVal += stepSizeVector.Y
			end
		end
		ScannerManager.scanning = false
		ScannerManager.scannable = true
		PlayerUtils.ToggleLockCamera()
		PlayerUtils.ToggleLockPlayer()
		task.wait(ScannerManager.m2CooldownTime)
		ScannerManager.m2Cooldown = false

		plr.Character.Scanner.Scanner.TopScreen.BrickColor = BrickColor.new("Bright blue")
	end
end
return M2Scan
