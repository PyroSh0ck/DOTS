local M1Click = {}
local LaserUtils = require(script.Parent.LaserUtils)
local DotUtils = require(script.Parent.DotUtils)
local PlaceDotsEvent = game:GetService("ReplicatedStorage").Events.PlaceDots

function M1Click.HeldDown(scanner)
    local cam = game.Workspace.CurrentCamera
    if scanner.scannable then
        scanner:SetScanning(true)

        local origin = cam.CFrame.Position
        local directionVector = cam.CFrame.LookVector

        local resArr = DotUtils.GetDots(scanner, origin, directionVector)
        PlaceDotsEvent:FireServer(resArr)
        LaserUtils.DrawLasers(resArr, scanner.scannerToolRef)
    end
end

function M1Click.Released(scanner)
    scanner:SetScanning(false)
end

return M1Click
