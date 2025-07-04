local RaycastController = {}
local Workspace = game:GetService("Workspace")
print("RaycastController module loaded")
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = Workspace.Interactables:GetDescendants()
raycastParams.FilterType = Enum.RaycastFilterType.Include

function RaycastController:SendRaycast(origin, direction)
	return Workspace:Raycast(origin, direction, raycastParams)
end

return RaycastController
