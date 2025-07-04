local LaserDrawer = {}
print("LaserDrawer module loaded")
local RS = game:GetService("ReplicatedStorage")
local laser = RS:WaitForChild("Laser")
local Workspace = game:GetService("Workspace")
local scanningPortion = script.Parent.Parent.ScanningPortion.Position
function LaserDrawer.DrawLaser(res)
	local laserClone = laser:Clone()
	-- if laserClone then
	-- 	print("Laser template found in ReplicatedStorage.")
	-- else
	-- 	warn("Laser template not found in ReplicatedStorage.")
	-- 	return
	-- end
	-- print("8")
	laserClone.Parent = Workspace.Lasers
	local rotCFrame = CFrame.Angles(0, math.rad(90), 0)
	local offsetCFrame = CFrame.new((laserClone.Size.X * res.Distance) / 2, 0, 0)
	local initCFrame = CFrame.new(scanningPortion, res.Position)
	laserClone.Size = Vector3.new(laserClone.Size.X * res.Distance, laserClone.Size.Y, laserClone.Size.Z)
	laserClone.CFrame = initCFrame:ToWorldSpace(rotCFrame):ToWorldSpace(offsetCFrame)
	task.wait()
	laserClone:Destroy()
end

function LaserDrawer.DrawLasers(resArr)
	for _, res in ipairs(resArr) do
		-- local laserCor = coroutine.create(LaserDrawer.DrawLaser)
		-- coroutine.resume(laserCor, res)
		LaserDrawer.DrawLaser(res)
	end
end

return LaserDrawer
