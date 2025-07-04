local RadiusUtils = {}

local plr = game.Players.LocalPlayer
local radiusLabel = plr.PlayerGui.MainGui.MainFrame.RadiusLabel 
local waitTime = 0.4

function RadiusUtils.showRadiusErr(txt)
    local warningTxt = plr.PlayerGui.MainGui.MainFrame.WarningLabel

    warningTxt.Text = txt
    warningTxt.Visible = false

    for _i = 0, 3 do
        warningTxt.Visible = not warningTxt.Visible
        task.wait(waitTime)
    end
end

function RadiusUtils.HeldDown(scanner, keycode)
    local CurrentRadius = scanner.CurrentRadius
    local MAX_RADIUS = scanner.MAX_RADIUS
    local MIN_RADIUS = scanner.MIN_RADIUS

    if not scanner.scanning then
        scanner:SetScannable(false)
        if keycode == Enum.KeyCode.V then
            if CurrentRadius < MAX_RADIUS then
                scanner:ChangeRadius(1)
                radiusLabel.Text = "Radius: "..tostring(CurrentRadius)
            else
                RadiusUtils.showRadiusErr("WARNING: MAX RADIUS REACHED")
            end
        elseif keycode == Enum.KeyCode.C then
            if CurrentRadius > MIN_RADIUS then
                scanner:ChangeRadius(-1)
                radiusLabel.Text = "Radius: "..tostring(CurrentRadius)
            else
                RadiusUtils.showRadiusErr("WARNING: MIN RADIUS REACHED")
            end
        end
    end
end

function RadiusUtils.Released(scanner)
    scanner:SetScannable(true)
end

return RadiusUtils
