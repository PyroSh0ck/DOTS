local RaycastUtils = {}

function RaycastUtils.SendRaycast(origin, direction, raycastParams)
    return game.Workspace:Raycast(origin, direction, raycastParams)
end

return RaycastUtils
