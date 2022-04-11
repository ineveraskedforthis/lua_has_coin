--- Prices logic:
--- sell price - how much character can get for selling thing in this shop
--- buy price - how much character should pay to buy thing in this shop 
--- When someone buys, it increases buy price by 1 with some probability
--- When someone sells, it decreases sell price by 1 with some probability
--- During update, with some probability sell price rises and buy price falls

GOODS = {}
GOODS.POTION = "POTION"
GOODS.FOOD = "FOOD"

---@class Building
---@field _cell Position
---@field class number
---@field progress number
---@field wealth number
---@field wealth_before_tax number
---@field num_of_visitors number
---@field _buy_price number[]
---@field _sell_price number[]
---@field owner any
---@field _stash number[]
---@field _timer_sell number[]
---@field _timer_buy number[]
---@field _av_timer_sell number[]
---@field _av_timer_buy number[]
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
    building._sell_price = {}
    building._buy_price = {}
    building._stash = {}
    building._av_timer_buy = {}
    building._av_timer_sell = {}
    building._timer_buy = {}
    building._timer_sell = {}
    for _, v in pairs(GOODS) do
        building._sell_price[v] = 10
        building._buy_price[v] = 15
        building._av_timer_buy[v]   = 10000 --- frequency influences how often update should change price.
        building._av_timer_sell[v]  = 10000
        building._timer_buy[v]      = 0
        building._timer_sell[v]     = 0 
        building._stash[v] = 0
    end    
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

---updates state of shop after selling x to it  
---reduces stash and updates price
---@param x string
---@return EventSimple
function Building:update_on_sell(x)
    self._stash[x] = self._stash[x] + 1
    self._av_timer_sell[x] = self._av_timer_sell[x] * 9 / 10 + self._timer_sell[x] * 1 / 10
    self._timer_sell[x] = 0
    if math.random() > 0.8 then
        self._sell_price[x] = math.max(0, self._sell_price[x] - 1)
    end
    return Event_ActionFinished()
end
---updates state of shop after buying x from it  
---reduces stash and updates price
---@param x string
---@return EventSimple
function Building:update_on_buy(x)
    if self._stash[x] == 0 then
        return Event_ActionFailed()
    end
    self._stash[x] = self._stash[x] - 1
    self._av_timer_buy[x] = self._av_timer_buy[x] * 9 / 10 + self._timer_buy[x] * 1 / 10
    self._timer_buy[x] = 0
    if math.random() > 0.8 then
        self._buy_price[x] = self._buy_price[x] + 1
    end
    return Event_ActionFinished()
end

function Building:update()
    for k, v in pairs(GOODS) do
        self._timer_buy[v]      = self._timer_buy[v]    + 1
        self._timer_sell[v]     = self._timer_sell[v]   + 1
        if math.random() < 0.2 / self._av_timer_sell[v] then
            self._sell_price[v] = math.min(self._sell_price[v] + 1, math.floor(self:get_wealth() / 1.5))
        end
        if math.random() < 0.2 / self._av_timer_buy[v] then
            self._buy_price[v] = math.max(self._buy_price[v] - 1, 1)
        end
    end
end
---Returns price of x where x is one of GOODS  
---price for which you can sell there  
---@param x string
---@return number
function Building:get_sell_price(x)
    return self._sell_price[x]
end
---Returns price of x where x is one of GOODS  
---price for which you can buy there  
---@param x string
---@return number
function Building:get_buy_price(x)
    return self._buy_price[x]
end
---Returns remaining anount of x
---@param x string
---@return number
function Building:get_stash(x)
    return self._stash[x]
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


return Building