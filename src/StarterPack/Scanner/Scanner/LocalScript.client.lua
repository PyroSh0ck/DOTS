-- Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

-- Global Variables
-- Right now, all are random values
local scanning = false
local scannable = true
local m2Cooldown = false
local CameraLocked = false
local playerLocked = false
local equipped = false
local m2CooldownTime = 5
local radiusScaler = 19
local MAX_RADIUS = 15 								
local MIN_RADIUS = 1									
local CurrentRadius = 13
local timeBetweenRaycasts = 0.004
local timeBetweenRadiusChange = 0.1
local renderDistance = 50
local hScaleFactor = 1.5
local vScaleFactor = 1.5
local density = 10

-- Other Variables
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera
local PlaceDot = RS.Events.PlaceDot
local PlaceDots = RS.Events.PlaceDots
local randObj = Random.new(1)
task.wait(1)
local wallsFolder = game.Workspace.Interactables.Walls
local raycastParams = RaycastParams.new() 
raycastParams.FilterDescendantsInstances = game.Workspace.Interactables:GetDescendants()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local laser = RS.Laser
local scanningPortion = script.Parent.ScanningPortion
local radiusLabel = plr.PlayerGui.MainGui.MainFrame.RadiusLabel


-- Functions
function DrawLaser(res)
	local laserClone = laser:Clone()
	local rotCFrame = CFrame.Angles(0, math.rad(90), 0)
	local offsetCFrame = CFrame.new((laser.Size.X * res.Distance)/2, 0, 0)
	local initCFrame = CFrame.new(scanningPortion.Position, res.Position)
	laserClone.Size = Vector3.new(laser.Size.X * res.Distance, laser.Size.Y, laser.Size.Z)
	laserClone.CFrame = initCFrame:ToWorldSpace(rotCFrame):ToWorldSpace(offsetCFrame)
	laserClone.Parent = game.Workspace.Lasers
	task.wait()
	laserClone:Destroy()
end

function DrawLasers(resArr) 
	for _, res in ipairs (resArr) do
		local laserCor = coroutine.create(DrawLaser)
		coroutine.resume(laserCor, res)
	end
end

function SendRaycast(origin, direction) 
	return game.Workspace:Raycast(origin, direction, raycastParams)
end

function GetWiggle()
	local randNum = randObj:NextNumber(-1, 1)
	
	return (randNum/(radiusScaler - CurrentRadius))
end

function RandomizeAndFormatDirectionVector(directionVector)
	local tempVector = directionVector.Unit
	local resVector = Vector3.new(tempVector.X + GetWiggle(), tempVector.Y + GetWiggle(), tempVector.Z + GetWiggle())
	return (resVector.Unit * renderDistance)
end

function GetDots(origin, directionVector)
	local resArr = {}

	local counter = 0

	while counter < density do
		local modifiedDirectionVector = RandomizeAndFormatDirectionVector(directionVector)
		local raycastResult = SendRaycast(origin, modifiedDirectionVector)
		if raycastResult then
			--print(raycastResult.Instance)
			--print(raycastResult.Instance:GetAttribute("objectType"))
			local tempArr = {
				Distance = raycastResult.Distance,
				Position = raycastResult.Position,
				Normal = raycastResult.Normal,
				ObjectType = raycastResult.Instance:GetAttribute("objectType")
			}
			table.insert(resArr, tempArr)
		end
		counter += 1
	end

	return resArr
end

function MouseButton1HeldDown()
	if scannable then
		scanning = true
		--local origin = script.Parent.ScannerOrigin.Position
		local origin = camera.CFrame.Position --(better possible option?)
		local directionVector = camera.CFrame.LookVector
		
		local resArr = GetDots(origin, directionVector)
		PlaceDots:FireServer(resArr)
		DrawLasers(resArr)
	end
end

function MouseButton1Released()
	scanning = false
end

function ToggleLockCamera()
	if not CameraLocked then
		CameraLocked = true
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = camera.CFrame
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	elseif CameraLocked then
		CameraLocked = false
		camera.CameraType = Enum.CameraType.Custom
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end

function ToggleLockPlayer()
	if not playerLocked then
		if plr.Character then
			playerLocked = true
			plr.Character.Humanoid.WalkSpeed = 0
		else
			plr.CharacterAdded:Wait()
			ToggleLockPlayer()
		end
	elseif playerLocked then
		playerLocked = false
		plr.Character.Humanoid.WalkSpeed = 16
	end
		
end

function ScaledStepSize(viewportSize) 
	local ray1 = camera:ViewportPointToRay(0, 0)
	local ray2 = camera:ViewportPointToRay(viewportSize.X, 0)
	local ray3 = camera:ViewportPointToRay(0, viewportSize.Y)
	
	local res1 = SendRaycast(ray1.Origin, ray1.Direction.Unit * renderDistance)
	local res2 = SendRaycast(ray2.Origin, ray2.Direction.Unit * renderDistance)
	local res3 = SendRaycast(ray3.Origin, ray3.Direction.Unit * renderDistance)
	
	if res1 and res2 and res3 then
		local hdist = (res2.Position - res1.Position).Magnitude * hScaleFactor
		local vdist = (res3.Position - res1.Position).Magnitude * vScaleFactor

		return Vector2.new(viewportSize.X/(hdist), viewportSize.Y/(vdist))
	end
	return nil
	
end

function MouseButton2Click()
	if not scanning and not m2Cooldown then
		if scannable then
			scannable = false
			scanning = true

			ToggleLockCamera()
			ToggleLockPlayer()

			local viewportSize = camera.ViewportSize
						
			local xVal = 0
			local yVal = 0
			
			local stepSizeVector = ScaledStepSize(viewportSize)
			if stepSizeVector then
				local lastposition = Vector3.new(9e999, 9e999, 9e999)
				while (yVal + stepSizeVector.Y) < viewportSize.Y do
					while (xVal + stepSizeVector.X) < viewportSize.X do
						local ray = camera:ViewportPointToRay(xVal, yVal)
						local randomRay = RandomizeAndFormatDirectionVector(ray.Direction.Unit)
						local raycastResult = SendRaycast(ray.Origin, randomRay)
						if raycastResult ~= nil then

							if (lastposition - raycastResult.Position).Magnitude >= 1.5 then
								local laserCor = coroutine.create(DrawLaser)
								coroutine.resume(laserCor, raycastResult)
								PlaceDot:FireServer(raycastResult.Position, raycastResult.Normal)
								lastposition = raycastResult.Position
								if not m2Cooldown then
									m2Cooldown = true
									plr.Character.Scanner.Scanner.TopScreen.BrickColor =  BrickColor.new("Bright red")
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
			
			scanning = false
			scannable = true
			ToggleLockCamera()
			ToggleLockPlayer()
			task.wait(7)
			m2Cooldown = false
			plr.Character.Scanner.Scanner.TopScreen.BrickColor = BrickColor.new("Bright blue")
		end
	end
end

function showRadiusError(text)
	local waitTime = 0.4
	local warningTxt = plr.PlayerGui.MainGui.MainFrame.WarningLabel
	
	warningTxt.Text = text
	warningTxt.Visible = true
	task.wait(waitTime)
	warningTxt.Visible = false
	task.wait(waitTime)
	warningTxt.Visible = true
	task.wait(waitTime)
	warningTxt.Visible = false
	task.wait(waitTime)
	
end

function radiusHandlerHeldDown(keycode)
	if not scanning then
		scannable = false
		if keycode == Enum.KeyCode.V then
			if CurrentRadius < MAX_RADIUS then
				CurrentRadius += 1
				radiusLabel.Text = "Radius: "..tostring(CurrentRadius)
			else
				showRadiusError("WARNING: MAX RADIUS REACHED")
			end
		elseif keycode == Enum.KeyCode.C then
			if CurrentRadius > MIN_RADIUS then
				CurrentRadius -= 1
				radiusLabel.Text = "Radius: "..tostring(CurrentRadius)
			else
				showRadiusError("WARNING: MIN RADIUS REACHED")
			end
		end
	end
end

function radiusHandlerReleased()
	scannable = true
end

-- Events

-- This code works no touchy
script.Parent.Parent.Equipped:Connect(function()
	equipped = true
end)
script.Parent.Parent.Unequipped:Connect(function()
	equipped = false
end)

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if equipped then
		if input.UserInputType == Enum.UserInputType.MouseButton1  then

			while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				MouseButton1HeldDown()
				task.wait(timeBetweenRaycasts)
			end
			MouseButton1Released()

		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then 
			MouseButton2Click()
		end

		if input.KeyCode == Enum.KeyCode.V then

			while UIS:IsKeyDown(Enum.KeyCode.V) do
				radiusHandlerHeldDown(input.KeyCode)
				task.wait(timeBetweenRadiusChange)
			end
			radiusHandlerReleased()
		end

		if input.KeyCode == Enum.KeyCode.C then

			while UIS:IsKeyDown(Enum.KeyCode.C) do
				radiusHandlerHeldDown(input.KeyCode)
				task.wait(timeBetweenRadiusChange)
			end
			radiusHandlerReleased()
		end
	end
		
end)