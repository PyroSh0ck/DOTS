local ClassUtils = require(game:GetService("ReplicatedStorage").Shared.ClassUtils)
local M1Click = require(script.M1Click)
local M2Click = require(script.M2Click)
local RadiusUtils = require(script.RadiusUtils)

local Scanner = ClassUtils.class{
    timeBetweenRaycasts = 0.004,
    timeBetweenRadiusChange = 0.1
}

Scanner.__index = Scanner

function Scanner:__init(m2CooldownTime, MAX_RADIUS, MIN_RADIUS, renderDistance, density, raycastParams, scannerToolRef)

    self.m2CooldownTime = m2CooldownTime
    self.MAX_RADIUS = MAX_RADIUS
    self.MIN_RADIUS = MIN_RADIUS
    self.renderDistance = renderDistance
    self.density = density
    self.raycastParams = raycastParams
    self.scannerToolRef = scannerToolRef

    self.scanning = false
    self.scannable = false
    self.equipped = false
    self.CurrentRadius = 13
    self.m2Cooldown = false

end

function Scanner:ChangeRadius(amount)
    self.CurrentRadius += amount
end

function Scanner:SetEquipped(bool)
    self.equipped = bool
end

function Scanner:SetScannable(bool)
    self.scannable = bool
end

function Scanner:SetScanning(bool)
    self.scanning = bool
end

function Scanner:SetM2Cooldown(bool)
    self.m2Cooldown = bool
end

function Scanner:MouseButton1HeldDown()
    M1Click.HeldDown(self)
end

function Scanner:MouseButton1Released()
    M1Click.Released(self)
end

function Scanner:MouseButton2HeldDown()
    M2Click.Click(self)
end

function Scanner:RadiusHandlerHeldDown(keycode)
    RadiusUtils.HeldDown(self, keycode)
end

function Scanner:RadiusHandlerReleased()
    RadiusUtils.Released(self)
end

return Scanner
