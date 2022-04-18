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
---@field num_of_visitors number
---@field FOOD_PRICE number
---@field POTION_PRICE number
---@field SLEEP_PRICE number
---@field HUNT_REWARD number
---@field CONTRACT_TIME number
---@field budget Budget
---@field wealth number
---@field hunt_wealth number
---@field hunt_wealth_reserved number
---@field INCOME_TAX number
---@field tax_collectors Character[]
---@field open_tax_collector_positions number
---@field tax_collection_reward number
---@field payment_timer number[]
---@field vacant_job boolean
---@field free_contract_id number
---@field contracts Contract[]
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
        hunt_wealth = 0,
        hunt_wealth_reserved = 0,
        num_of_visitors = 0,
        FOOD_PRICE = 10,
        POTION_PRICE = 10,
        SLEEP_PRICE = 2,
        HUNT_REWARD = 10,
        CONTRACT_TIME = 10,
        free_contract_id = 0,
        budget = Budget:new(),
        INCOME_TAX = 10,
        tax_collectors = {},
        open_tax_collector_positions = 0,
        tax_collection_reward= 20,
        vacant_job= false,
        payment_timer= {0, 0, 0, 0, 0, 0, 0, 0, 0},
        contracts = {}
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

---Returns a contract on rat-hunting with current reward/timer
---Supposed to be run from character?
---@param character Character
---@return Contract|nil
function Castle:claim_reward(character)
    if self.HUNT_REWARD <= self.hunt_wealth then
        self.hunt_wealth_reserved = self.hunt_wealth_reserved + self.HUNT_REWARD
        self.hunt_wealth = self.hunt_wealth - self.HUNT_REWARD
        local contract = Contract:new(self.free_contract_id, character, 'rat', self.HUNT_REWARD, DATE + self.CONTRACT_TIME)
        self.contracts[self.free_contract_id] = contract
        self.free_contract_id = self.free_contract_id + 1
        return contract
    end    
end

---Gives a **reward** specified in **contract** to a contract's **character** and removes contract from character
---@param contract Contract
function Castle:give_reward(contract)
    if contract == nil then
        return Event_ActionFailed()
    end
    local character = contract.character
    if character.stash == contract.goal then
        self.hunt_wealth_reserved = self.hunt_wealth_reserved - contract.reward
        character:add_wealth(contract.reward)
        character:remove_contract()
        return Event_ActionFinished()
    end
    return Event_ActionFailed()
end

---cancels contract and removes it from character
---@param contract Contract
function Castle:cancel_contract(contract)
    self.hunt_wealth_reserved = self.hunt_wealth_reserved - contract.reward
    self.hunt_wealth = self.hunt_wealth + contract.reward
    self.contracts[contract.id] = nil
    contract.character:remove_contract()
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
    -- if self.wealth >= 100 then
    --     -- self.wealth = self.wealth - 100
    --     -- new_hero(100)
    -- end
end

---if character is employed here then pay tax_collection_reward to him
---@param character Character
function Castle:pay_earnings(character)
    if character.job_index == nil then
        return Event_ActionFailed()
    end
    if self.payment_timer[character.job_index] == 100 then
        if self.wealth > self.tax_collection_reward then
            self.wealth = self.wealth - self.tax_collection_reward
            character:add_wealth(self.tax_collection_reward)
            self.payment_timer[character.job_index] = 0
            return Event_ActionFinished()
        end
    end
    return Event_ActionFailed()
end

function Castle:payment_ready(character)
    if character.job_index == nil then
        return false
    end
    if self.payment_timer[character.job_index] == 100 then
        if self.wealth > self.tax_collection_reward then
            return true
        end
    end
    return false
end

function Castle:open_tax_collector_position()
    if self.open_tax_collector_positions < 7 then
        self.open_tax_collector_positions = self.open_tax_collector_positions + 1
        self.vacant_job = true
    end
end

function Castle:has_vacant_job() 
    return self.vacant_job
end

function Castle:close_tax_collector_position()
    local last = self.open_tax_collector_positions
    if last == 0 then
        return
    end
    if self.tax_collectors[last] == nil then
        self.open_tax_collector_positions = last - 1
        return
    end
    for i = 1, last - 1 do
        if self.tax_collectors[i] == nil then
            self.tax_collectors[i] = self.tax_collectors[self.open_tax_collector_positions]
            self.tax_collectors[last] = nil
            tax_collectors_list[last]:update_label("- Empty")
            self.open_tax_collector_positions = last - 1
            return
        end
    end
    self.tax_collectors[last].fire("tax_collector")
    tax_collectors_list[last]:update_label("- Empty")
    self.tax_collectors[last] = nil
    self.open_tax_collector_positions = last - 1
end

---Apply character to tax collector office
---@param character Character
---@return EventSimple
function Castle:apply_for_office(character)
    for _ = 1, self.open_tax_collector_positions do
        local i = self.tax_collectors[_]
        if i == nil then
            self.tax_collectors[_] = character
            character:hire("tax_collector", _)
            tax_collectors_list[_]:update_label("- " .. character.name)
            return Event_ActionFinished()
        end
    end
    self.vacant_job =  false
    return Event_ActionFailed()
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

---Updates state of castle
function Castle:update()
    for _, i in pairs(self.tax_collectors) do
        if self.payment_timer[_] < 100 then
            self.payment_timer[_] = self.payment_timer[_] + 1
        end
    end

    local expired_contracts = {}
    for _, i in pairs(self.contracts) do

        if i.expires_at < DATE then
            table.insert(expired_contracts, i)
        end
    end
    for _, i in pairs(expired_contracts) do
        self:cancel_contract(i)
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
    self.hunt_wealth = self.hunt_wealth + tmp
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