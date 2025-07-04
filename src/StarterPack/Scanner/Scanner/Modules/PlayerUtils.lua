local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
print("PlayerUtils module loaded")
local PlayerUtils = {
	CameraLocked = false,
	PlayerLocked = false,
}

function PlayerUtils:ToggleLockCamera()
	if not PlayerUtils.CameraLocked then
		PlayerUtils.CameraLocked = true
		camera.CameraType = Enum.CameraType.Scriptable
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		PlayerUtils.CameraLocked = false
		camera.CameraType = Enum.CameraType.Custom
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end

function PlayerUtils:ToggleLockPlayer()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	if not PlayerUtils.PlayerLocked then
		hum.WalkSpeed = 0
	else
		hum.WalkSpeed = 16
	end
	PlayerUtils.PlayerLocked = not PlayerUtils.PlayerLocked
end

return PlayerUtils
