local CameraUtils = {
    CameraLocked = false,
    camera = game.Workspace.CurrentCamera
}

local UIS = game:GetService("UserInputService")

function CameraUtils.ToggleLockCamera()
    local camLocked = CameraUtils.CameraLocked --read only for obvious reasons (but imma forget it so I have to write this)
    local cam = CameraUtils.camera -- not read only because its a ref to the camera object
    if not camLocked then
        CameraUtils.CameraLocked = true
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = cam.CFrame
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    elseif camLocked then
        CameraUtils.CameraLocked = false
        cam.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end

return CameraUtils
