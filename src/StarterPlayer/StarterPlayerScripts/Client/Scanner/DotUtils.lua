local RaycastUtils = require(script.Parent.RaycastUtils)
local DotUtils = {
    radiusScaler = 4,
    randObj = Random.new(1)
}

function DotUtils.GetWiggle(scanner)
    local randNum = DotUtils.randObj:NextNumber(-1, 1)

    return (randNum / scanner.MAX_RADIUS + DotUtils.radiusScaler - scanner.CurrentRadius)
end

function DotUtils.RandomizeAndFormatDirectionVector(directionVector, scanner)
    local tempVector = directionVector.Unit
    local resVector = Vector3.new(tempVector.X + DotUtils.GetWiggle(scanner), tempVector.Y + DotUtils.GetWiggle(scanner), tempVector.Z + DotUtils.GetWiggle(scanner))
    return (resVector.Unit * scanner.renderDistance)
end

function DotUtils.GetDots(scanner, origin, directionVector)
    local resArr = {}
    local counter = 0

    while counter < scanner.desnity do
        local modifiedDirectionVector = DotUtils.RandomizeAndFormatDirectionVector(directionVector, scanner)
        local raycastResult = RaycastUtils.SendRaycast(origin, modifiedDirectionVector, scanner.raycastParams)
        if raycastResult then
            local tempArr = {
                Distance = raycastResult.Distance,
                Position = raycastResult.Position,
                Normal = raycastResult.Normal,
                ObjectType = raycastResult.Instance:GetAttribute("objectType")
            }
            table.insert(resArr, tempArr)
        end
        counter += 1
    end

    return resArr
end

return DotUtils
