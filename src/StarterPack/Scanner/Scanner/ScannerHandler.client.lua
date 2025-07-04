local Scanner = require(game.Players.LocalPlayer.PlayerScripts.Client.Scanner)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = game.Workspace.Interactables:GetDescendants()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local scannerTool = script.Parent.Parent
local UIS = game:GetService("UserInputService")

local scannerObj = Scanner(5, 15, 1, 50, 10, raycastParams, scannerTool)

scannerTool.Equipped:Connect(function()
    scannerObj:SetEquipped(true)
    scannerObj:SetScannable(true)
end)

scannerTool.Unequipped:Connect(function()
    scannerObj:SetEquipped(false)
    scannerObj:SetScannable(false)
end)

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            scannerObj:MouseButton1HeldDown()
            task.wait(scannerObj.timeBetweenRaycasts)
        end
        scannerObj:MouseButton1Released()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        scannerObj:MouseButton2HeldDown()
    end

    if input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.C then
        while UIS:IsKeyDown(input.KeyCode) do
            scannerObj:RadiusHandlerHeldDown(input.KeyCode)
            task.wait(scannerObj.timeBetweenRadiusChange)
        end
        scannerObj:RadiusHandlerReleased()
    end
end)
