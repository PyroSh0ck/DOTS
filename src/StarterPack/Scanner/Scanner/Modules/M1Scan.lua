local M1Scan = {}
print("M1Scan module loaded")
local ScannerManager = require(script.Parent.ScannerManager)
local LaserDrawer = require(script.Parent.LaserDrawer)
local RaycastController = require(script.Parent.RaycastController)

local RS = game:GetService("ReplicatedStorage")
local PlaceDots = RS.Events.PlaceDots
local camera = workspace.CurrentCamera

function M1Scan:GetDots(origin, directionVector)
	local resArr = {}
	local counter = 0
	while counter < ScannerManager.density do
		local modifiedDirectionVector = ScannerManager:RandomizeDirection(directionVector)
		local raycastResult = RaycastController:SendRaycast(origin, modifiedDirectionVector)
		if raycastResult then
			--print(raycastResult.Instance)
			--print(raycastResult.Instance:GetAttribute("objectType"))
			local tempArr = {
				Distance = raycastResult.Distance,
				Position = raycastResult.Position,
				Normal = raycastResult.Normal,
				ObjectType = raycastResult.Instance:GetAttribute("objectType"),
			}
			table.insert(resArr, tempArr)
		end
		counter += 1
	end

	return resArr
end

function M1Scan:Scan()
	if ScannerManager.scannable then
		ScannerManager.scanning = true
		local origin = camera.CFrame.Position
		local directionVector = camera.CFrame.LookVector
		local resArr = M1Scan:GetDots(origin, directionVector)
		PlaceDots:FireServer(resArr)
		LaserDrawer.DrawLasers(resArr)
	end
end

return M1Scan
