local ScannerManager = {}
print("ScannerManager module loaded")
local RadiusManager = require(script.Parent.RadiusManager)

ScannerManager.renderDistance = 50
ScannerManager.hScaleFactor = 1.5
ScannerManager.vScaleFactor = 1.5
ScannerManager.radiusScaler = 19

local randomGen = Random.new(1)

ScannerManager.scanning = false
ScannerManager.scannable = true
ScannerManager.m2Cooldown = false
ScannerManager.m2CooldownTime = 7
ScannerManager.density = 10

function ScannerManager:GetWiggle()
	return randomGen:NextNumber(-1, 1) / (ScannerManager.radiusScaler - RadiusManager.CurrentRadius)
end

function ScannerManager:RandomizeDirection(dir)
	local tempVector = dir.Unit
	local resVector =
		Vector3.new(tempVector.X + self:GetWiggle(), tempVector.Y + self:GetWiggle(), tempVector.Z + self:GetWiggle())
	return resVector.Unit * ScannerManager.renderDistance
end

return ScannerManager
