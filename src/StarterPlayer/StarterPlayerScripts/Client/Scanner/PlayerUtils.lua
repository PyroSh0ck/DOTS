local PlayerUtils = {
    playerLocked = false
}

local plr = game.Players.LocalPlayer

function PlayerUtils.ToggleLockPlayer()
    if not PlayerUtils.playerLocked then
        if plr.Character then
            PlayerUtils.playerLocked = true
            plr.Character.Humanoid.WalkSpeed = 0
        else
            plr.CharacterAdded:Wait()
            PlayerUtils.ToggleLockPlayer()
        end
    elseif PlayerUtils.playerLocked then
        PlayerUtils.playerLocked = false
        plr.Character.Humanoid.WalkSpeed = 16
    end
end

return PlayerUtils
