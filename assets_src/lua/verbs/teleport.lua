local Functional = require "halley/functional"
local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"


local Teleport = Verb:new()


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
    local u = Wargroove.getUnitAt(targetPos)
    local fromTerrainName = Wargroove.getTerrainNameAt(endPos)
    local toTerrainName = Wargroove.getTerrainNameAt(targetPos)
    return u == nil and fromTerrainName == "teleporter" and toTerrainName == "teleporter"
end

function Teleport:execute(unit, targetPos, strParam, path)

    print("From", unit.pos.x, unit.pos.y)
    print("Going to", targetPos.x, targetPos.y)

    Wargroove.spawnPaletteSwappedMapAnimation(unit.pos, 0, "fx/groove/nuru_groove_fx", unit.playerId)
    Wargroove.playMapSound("cutscene/teleportOut", targetPos)

    -- Somehow make unit disappear
    unit.inTransport = true
    Wargroove.updateUnit(unit)

    Wargroove.waitTime(1)

    -- Somehow make unit reappear
    unit.inTransport = false
    Wargroove.updateUnit(unit)
    
    Wargroove.spawnPaletteSwappedMapAnimation(targetPos, 0, "fx/groove/nuru_groove_fx", unit.playerId)
    Wargroove.playMapSound("cutscene/teleportIn", targetPos)

    Wargroove.waitTime(0.2)

end

function Teleport:onPostUpdateUnit(unit, targetPos, strParam, path)
    unit.pos = { x = targetPos.x, y = targetPos.y }
end

return Teleport
