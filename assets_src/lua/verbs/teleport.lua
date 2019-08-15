local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"


local Teleport = Verb:new()

function Teleport:getTargets(unit, endPos, strParam)
    return Functional.filter(function (targetPos)
        return self:canExecuteWithTarget(unit, endPos, targetPos, strParam)
    end, Wargroove.getTargetsInRange(endPos, 20, nil)) -- GET TARGETS FROM ENTIRE MAP
end

function Teleport:canExecuteAt(unit, endPos)
    local terrainName = Wargroove.getTerrainNameAt(endPos)
    return terrainName == "teleporter"
end

function Teleport:canExecuteWithTarget(unit, endPos, targetPos, strParam)
    local fromTerrainName = Wargroove.getTerrainNameAt(endPos)
    local toTerrainName = Wargroove.getTerrainNameAt(targetPos)
    return fromTerrainName == "teleporter" and toTerrainName == "teleporter"
end

function Teleport:execute(unit, targetPos, strParam, path)
    unit.pos = { x = targetPos.x, y = targetPos.y }
    Wargroove.updateUnit(unit)
end

return Teleport
