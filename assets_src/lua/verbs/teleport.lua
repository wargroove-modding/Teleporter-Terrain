local Functional = require "halley/functional"
local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"


local Teleport = Verb:new()


function Teleport:isInRange()
    return true
end

function Teleport:getTargetType()
    return "empty"
end

function Teleport:getFullMapTargets(pos, range, targetType)
    local mapSize = Wargroove.getMapSize()

    local result = {}
    for x = 0,  mapSize.x do
        for y = 0,  mapSize.x do
            table.insert(result, { x = x, y = y})
        end
    end
    return result
end

function Teleport:getTargets(unit, endPos, strParam)
    return Functional.filter(function (targetPos)
        return self:canExecuteWithTarget(unit, endPos, targetPos, strParam)
    end, self:getFullMapTargets(nil))
end

function Teleport:canExecuteAt(unit, endPos)
    local terrainName = Wargroove.getTerrainNameAt(endPos)
    return terrainName == "teleporter"
end

function Teleport:canExecuteWithTarget(unit, endPos, targetPos, strParam)
    if not self:canSeeTarget(targetPos) then
        return false
    end

    local u = Wargroove.getUnitAt(targetPos)
    local fromTerrainName = Wargroove.getTerrainNameAt(endPos)
    local toTerrainName = Wargroove.getTerrainNameAt(targetPos)
    return u == nil and fromTerrainName == "teleporter" and toTerrainName == "teleporter"
end

function Teleport:execute(unit, targetPos, strParam, path)

    Wargroove.spawnPaletteSwappedMapAnimation(unit.pos, 0, "fx/groove/nuru_groove_fx", unit.playerId)
    Wargroove.playMapSound("cutscene/teleportOut", targetPos)

    Wargroove.waitTime(0.1)
    
    Wargroove.setVisibleOverride(unit.id, false)

    Wargroove.waitTime(0.9)
    
    Wargroove.spawnPaletteSwappedMapAnimation(targetPos, 0, "fx/groove/nuru_groove_fx", unit.playerId)
    Wargroove.playMapSound("cutscene/teleportIn", targetPos)

    Wargroove.waitTime(0.2)

end

function Teleport:onPostUpdateUnit(unit, targetPos, strParam, path)
    unit.pos = { x = targetPos.x, y = targetPos.y }
    Wargroove.setVisibleOverride(unit.id, true)
end

function Teleport:generateOrders(unitId, canMove)
    local orders = {}

    local unit = Wargroove.getUnitById(unitId)
    local unitClass = Wargroove.getUnitClass(unit.unitClassId)
    local movePositions = {}
    if canMove then
        movePositions = Wargroove.getTargetsInRange(unit.pos, unitClass.moveRange, "empty")
    end
    table.insert(movePositions, unit.pos)

    for _, pos in pairs(movePositions) do
        if self:canExecuteAt(unit, pos) then
            local targets = self:getTargets(unit, pos, "")
            for _, targetPos in ipairs(targets) do
                orders[#orders+1] = { targetPosition = targetPos, strParam = "", movePosition = pos, endPosition = pos }
            end
        end
    end

    return orders
end

function Teleport:getScore(unitId, order)
    local unit = Wargroove.getUnitById(unitId)

    -- Calculate score of just BEING on the targetPos, because that's all it is
    local move_score = Wargroove.getAILocationScore(unit.unitClassId, order.targetPosition)

    return { score = move_score }
end

return Teleport
