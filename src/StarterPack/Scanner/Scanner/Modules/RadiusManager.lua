local RadiusManager = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
print("RadiusManager module loaded")
RadiusManager.CurrentRadius = 13
RadiusManager.MAX_RADIUS = 15
RadiusManager.MIN_RADIUS = 1
RadiusManager.timeBetweenWarnings = 0.4

local radiusLabel = player:WaitForChild("PlayerGui").MainGui.MainFrame.RadiusLabel
local warningTxt = player.PlayerGui.MainGui.MainFrame.WarningLabel

function RadiusManager:AdjustRadius(change)
	local newVal = self.CurrentRadius + change
	if newVal > self.MAX_RADIUS then
		self:ShowError("WARNING: MAX RADIUS REACHED")
	elseif newVal < self.MIN_RADIUS then
		self:ShowError("WARNING: MIN RADIUS REACHED")
	else
		self.CurrentRadius = newVal
		radiusLabel.Text = "Radius: " .. tostring(self.CurrentRadius)
	end
end

function RadiusManager:ShowError(text)
	warningTxt.Text = text
	warningTxt.Visible = true
	task.wait(self.timeBetweenWarnings)
	warningTxt.Visible = false
	task.wait(self.timeBetweenWarnings)
	warningTxt.Visible = true
	task.wait(self.timeBetweenWarnings)
	warningTxt.Visible = false
end

return RadiusManager
