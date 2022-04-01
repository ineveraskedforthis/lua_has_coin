--- Prices logic:
--- sell price - how much character can get for selling thing in this shop
--- buy price - how much character should pay to buy thing in this shop 
--- When someone buys, it increases buy price by 1 with some probability
--- When someone sells, it decreases sell price by 1 with some probability
--- During update, with some probability sell price rises and buy price falls

---@class Building
---@field _cell Position
---@field class number
---@field progress number
---@field wealth number
---@field food_price_buy number
---@field food_price_sell number
---@field wealth_before_tax number
---@field num_of_visitors number
---@field buy_price number
---@field sell_price number
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
    building.food_price_sell = 10
    building.food_price_buy = 15
    building.sell_price = 10
    building.buy_price = 15
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

---Adds x wealth (subjected to taxes) to building
---@param x number
function Building:add_wealth(x)
    self.wealth_before_tax = self.wealth_before_tax + x
end

---Gets total wealth of building, both taxed and untaxed
---@return number
function Building:get_wealth()
    return self.wealth + self.wealth_before_tax
end

---Pays money to target character
---@param target Character
---@param x number
function Building:pay(target, x)
    if self:get_wealth() > x then
        if self.wealth_before_tax > x then
            self.wealth_before_tax = self.wealth_before_tax - x
            target.wealth = target.wealth + x
            return Event_ActionFinished()
        end
        self.wealth = self.wealth + self.wealth_before_tax - x
        self.wealth_before_tax = 0
        target.wealth = target.wealth + x
        return Event_ActionFinished()
    end
    return Event_ActionFailed()
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