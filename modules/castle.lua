---@class Budget 
---@field hunt number
---@field treasury number
Budget = {}
Budget.__index = Budget

---comment
---@return Budget
function Budget:new()
    _ = {hunt = 0, treasury = 100}
    setmetatable(_, Budget)
    return _
end

---takes tags: "hunt", increase corresponding budget
---@param tag "hunt"
function Budget:inc(tag)
    if tag == 'hunt' then
        if (self.hunt == 100) then
            return
        end
        self.hunt = self.hunt + 10
        self.treasury = self.treasury - 10
    end
end

---takes tags: "hunt", increase corresponding budget
---@param tag "hunt"
function Budget:dec(tag)
    if tag == 'hunt' then
        if (self.hunt == 0) then
            return
        end
        self.hunt = self.hunt - 10
        self.treasury = self.treasury + 10
    end
end

---@class Castle
---@field _cell Position
---@field progress number
---@field wealth number
---@field num_of_visitors number
---@field FOOD_PRICE number
---@field POTION_PRICE number
---@field SLEEP_PRICE number
---@field HUNT_REWARD number
---@field budget Budget
---@field INCOME_TAX number
Castle = {}
Castle.__index = Castle
-- local globals = require('constants')



-- zones
ZONE_TYPE = {}
ZONE_TYPE.ATTACK = 1
ZONES = {}



---comment
---@param cell Position
---@param progress number
---@return Castle
function Castle:new(cell, progress, wealth)
    local _ = {
        entity_type = "CASTLE",
        _cell = cell,
        progress = progress,
        wealth = wealth,
        hunt_budget = 0,
        reserved_hunt_budget = 0,
        num_of_visitors = 0,
        FOOD_PRICE = 10,
        POTION_PRICE = 10,
        SLEEP_PRICE = 10,
        HUNT_REWARD = 10,
        budget = Budget:new(),
        INCOME_TAX = 10,
    }
    setmetatable(_, self)
    return _
end

---comment
---@param x number
function Castle:add_wealth(x)
    self.wealth = self.wealth + x
end

---comment
---@return Position
function Castle:get_pos()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x = self._cell.x * grid_size + grid_size/2, y = self._cell.y * grid_size + grid_size/2}
end

function Castle:pos()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return self:get_pos()
end

---comment
---@return Position
function Castle:get_cell()
    return self._cell
end

---comment
---@param agent Character
function Castle:enter(agent)
    self.num_of_visitors = self.num_of_visitors + 1
end

---comment
---@param agent Character
function Castle:exit(agent)
    self.num_of_visitors = self.num_of_visitors - 1
end


-- actions of a king
---hires a new hero (NOT TESTED)
function Castle:hire_hero()
    if self.wealth >= 100 then
        self.wealth = self.wealth - 100
        new_hero(100)
    end
end

---increases hunt budget by 10%
function Castle:add_hunt_budget()
    if self.wealth >= 100 then
        self.wealth = self.wealth - 100
        self.hunt_budget = self.hunt_budget + 100
    else 
        self.hunt_budget = self.hunt_budget + self.wealth
        self.wealth = 0
    end
end


function Castle:dec_inv(tag)
    self.budget:dec(tag)
end
function Castle:inc_inv(tag)
    self.budget:inc(tag)
end


function Castle:dec_tax()
    if self.INCOME_TAX > 0 then
        self.INCOME_TAX = self.INCOME_TAX - 10
    end
end

function Castle:inc_tax()
    if self.INCOME_TAX < 100 then
        self.INCOME_TAX = self.INCOME_TAX + 10
    end
end


-- kingdom manipulatino
function Castle:income(t)
    local tmp = math.floor(self.budget.hunt * t / 100)
    self.wealth = self.wealth + t - tmp
    self.hunt_budget = self.hunt_budget + tmp
end






function Castle:new_zone(z_type, x1, y1, x2, y2)
    zone = {}
    zone.type = z_type
    zone.x1 = x1
    zone.x2 = x2
    zone.y1 = y1
    zone.y2 = y2
    table.insert(ZONES, zone)
end

function Castle:delete_zone(i)
    table.remove(ZONES, i)
end

function Castle:is_in_zone(type, x, y)
    for i, zone in pairs(ZONES) do
        if (x < zone.x1) and (zone.x1 < x) and (y < zone.y2) and (zone.y1 < y) then
            return true
        end
    end
    return false
end


return Castle