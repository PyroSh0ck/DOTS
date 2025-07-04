local SS = game:GetService("ServerStorage")

local wallColor = Color3.fromRGB(163, 162, 165)
local entityColor = Color3.new(1, 0, 0)

function PlaceDot(position, normal, objectType)
	local dot = SS.Dot:Clone()
	dot.Parent = game.Workspace.Dots
	
	--[[
		I need to add the position and normal vectors because the normal vectors are unit vectors.
		Meaning that if i were to just set the orientation to the normal vector, the circles would point towards the
		coordinates (1, 0, 0) for example, even if they were at the position -29, 39, 40. Thus, the circles wouldn't be facing
		outwards from the surface. By adding the two however, we get a position vector (not the same thing as the variable
		"position"; rather, this is a linear algebra term for a vector that starts from the origin) that starts from the origin
		and ends up (1, 0, 0) past the position (-29, 39, 40) for example. However, because the pivot point for cylinders
		points out of the lateral side instead of the circle side, I needed an offset of 90 degrees for the y value 
		of the orientation (hence the dot.CFrame:ToWorldSpace() method, as that rotates the object relative to itself)
	]]
	
	--local touchcheck = SS.TouchCheckPart:Clone()
	--touchcheck.Parent = game.Workspace
	--touchcheck.CFrame = CFrame.new(position, position + normal)
	--touchcheck.CFrame = dot.CFrame:ToWorldSpace(CFrame.Angles(0, math.rad(90), 0))
	dot.CFrame = CFrame.new(position, position + normal)
	dot.CFrame = dot.CFrame:ToWorldSpace(CFrame.Angles(0, math.rad(90), 0))
	local touchingParts = dot:GetTouchingParts()
	local numberTouching = 0
	for _, v in pairs(touchingParts) do
		if (v.Name == "Dot") then
			numberTouching += 1
		end 
	end
	
	if numberTouching >= 1 then
		dot:Destroy()
		return
	end
	
	--print(objectType)
	if objectType == "wall" then
		dot.Color = wallColor
	elseif objectType == "entity" then
		dot.Color = entityColor
	end
end

function PlaceDots(resArray)
	for _, res in ipairs(resArray) do
		PlaceDot(res.Position, res.Normal, res.ObjectType)
	end
end

game:GetService("ReplicatedStorage").Events.PlaceDot.OnServerEvent:Connect(function(plr, pos, normal)
	PlaceDot(pos, normal)
end)

game:GetService("ReplicatedStorage").Events.PlaceDots.OnServerEvent:Connect(function(plr, resArr)
	PlaceDots(resArr)
end)