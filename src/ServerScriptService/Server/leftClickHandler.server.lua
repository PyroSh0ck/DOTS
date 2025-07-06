local SS = game:GetService("ServerStorage")
local Events = game:GetService("ReplicatedStorage").Events
local wallColor = Color3.fromRGB(163, 162, 165)
local entityColor = Color3.new(1, 0, 0)

function PlaceDot(pos, normal, objectType)
	local dot = SS.Dot:Clone()
	dot.Parent = game.Workspace.Dots
	dot.CFrame = CFrame.new(pos, pos + normal)
	dot.CFrame = dot.CFrame:ToWorldSpace(CFrame.Angles(0, math.rad(90), 0))

	local touchingParts = dot:GetTouchingParts()
	local numberTouching = 0
	for _, v in ipairs(touchingParts) do
		if v.Name == "Dot" then
			numberTouching += 1
		end
	end

	if numberTouching >= 1 then
		dot:Destroy()
	end

	if objectType == "wall" then
		dot.Color = wallColor
	elseif objectType == "entity" then
		dot.Color = entityColor
	end
end

function PlaceDots(resArr)
	for _, res in ipairs(resArr) do
		PlaceDot(res.Position, res.Normal, res.ObjectType)
	end
end

Events.PlaceDot.OnServerEvent:Connect(function(_plr, ...)
	PlaceDot(...)
end)

Events.PlaceDots.OnServerEvent:Connect(function(_plr, ...)
	PlaceDots(...)
end)
