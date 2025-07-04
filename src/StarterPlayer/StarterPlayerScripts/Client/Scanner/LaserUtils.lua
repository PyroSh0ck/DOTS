local LaserUtils = {}
local laser = game:GetService("ReplicatedStorage").Laser

function LaserUtils.DrawLaser(res, scannerToolRef)
    local scanningPortion = scannerToolRef.Scanner.ScanningPortion
    local laserClone = laser:Clone()
    local rotCFrame = CFrame.Angles(0, math.rad(90), 0)
    local offsetCFrame = CFrame.new((laser.Size.X * res.Distance) / 2, 0, 0)
    local initCFrame = CFrame.new(scanningPortion.Position, res.Position)
    laserClone.Size = Vector3.new(laser.Size.X * res.Distance, laser.Size.Y, laser.Size.Z)
    laserClone.CFrame = initCFrame:ToWorldSpace(rotCFrame):ToWorldSpace(offsetCFrame)
    laserClone.Parent = game.Workspace.Lasers
    task.wait()
    laserClone:Destroy()
end

function LaserUtils.DrawLasers(resArr, scannerToolRef)
    for _, res in ipairs(resArr) do
        local laserCor = coroutine.create(LaserUtils.DrawLaser)
        coroutine.resume(laserCor, res, scannerToolRef)
    end
end

return LaserUtils
