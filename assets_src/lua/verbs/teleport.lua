local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"


local Teleport = Verb:new()

function Teleport:canExecuteAt(unit, endPos)
    local terrainName = Wargroove.getTerrainNameAt(endPos)
    return terrainName == "teleporter"
end

function Teleport:execute(unit, targetPos, strParam, path)
    unit:setHealth(50, unit.id)
end

return Teleport
