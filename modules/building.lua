---@class Building
---@field _cell Position
---@field class number
---@field progress number
---@field wealth number
---@field wealth_before_tax number
---@field num_of_visitors number
---@field price number
---@field owner any
---@field stash number
Building = {}
Building.__index = Building
-- local globals = require('constants')



---@alias BuildingClass "shop"|"home"
---@alias ShopType "food"|"potion"

---comment
---@param cell Position
---@param class BuildingClass
---@param progress number
---@param owner any
---@return Building
function Building:new(cell, class, progress, owner)
    local building = {entity_type = "BUILDING"}
    setmetatable(building, self)
    building._cell = cell
    building.class = class
    building.progress = progress
    building.owner = owner
    building.wealth = 0
    building.wealth_before_tax = 0
    building.num_of_visitors = 0
    building.price = 999
    building.stash = 0
    return building
end

---Returns coordinate of building
---@return Position
function Building:pos()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x = self._cell.x * grid_size + grid_size/2, y = self._cell.y * grid_size + grid_size/2}
end

---Return cell of building
---@return Position
function Building:cell()
    return self._cell
end

---comment
---@param agent Character
function Building:enter(agent)
    self.num_of_visitors = self.num_of_visitors + 1
end

---comment
---@param agent Character
function Building:exit(agent)
    self.num_of_visitors = self.num_of_visitors - 1
end

function Building:update()
end

return Building