---@class Cell
---@field x number
---@field y number
local Cell = {}
Cell.__index = Cell
---Creates new cell
---@param x number
---@param y number
function Cell:new(x, y)
    _ = {x=x, y=y}
    setmetatable(_, Cell)
    return _
end
function Cell:pos()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x = self.x * grid_size + grid_size/2, y = self.y * grid_size + grid_size/2}
end
function Cell:clone()
    _ = {x=self.x, y=self.y}
    setmetatable(_, Cell)
    return _
end
function Cell:center()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    local shift = grid_size / 2
    return {x = self.x * grid_size + shift, y = self.y * grid_size + shift}
end
---comment
---@param position Position
---@return Cell
function Cell:new_from_coordinate(position)
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return Cell:new(math.floor(position.x / grid_size), math.floor(position.y / grid_size))
end

return Cell