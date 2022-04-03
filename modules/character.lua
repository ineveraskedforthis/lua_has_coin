
---@type table<string, number>
MOVE_RESPONSE = enum {
    "TARGET_REACHED",
    "STILL_MOVING"
}

---@type table<string, number>
HP_RESPONSE = enum {
    "ALIVE",
    "DEAD"
}

---@type table<string, number>
ATTACK_RESPONSE = enum {
    "KILL",
    "DAMAGE",
    "NO_DAMAGE"
}

---@type table<string, number>
STASH = enum {
    "FOOD",
    "RAT",
    "NONE"
}

---@type table<string, number>
CHARACTER_STATE = enum {
    "MOVE_TO_TARGET",
    "ATTACK_TARGET",
    "REST",
    "PATROL",
    "BUY_FOOD",
    "BUY_POTION"
}

local moraes = {'xi', 'lo', 'mi', 'ki', 'a', 'i', 'ku'}


---@class Castle




---@class Quest
---@field castle Castle
---@field reward number



---@class Position
---@field x number
---@field y number



---returns vector FROM a TO b as first two numbers and vector's length
---@param a Target
---@param b Target
---@return number
---@return number
---@return number
function true_dist(a, b)
    dx = -a:pos().x + b:pos().x;
    dy = -a:pos().y + b:pos().y;
    return dx, dy, math.sqrt(dx * dx + dy * dy)
end


---@class Target
---@field position Position
---@field cell Cell
---@field cooldown number
Target = {position={x=nil, y=nil}, cooldown = 0, cell={x=nil, y=nil}}
Target.__index = Target
function Target:pos()
    return self.position
end

---comment
---@param pos Position
---@return Target
function Target:new(pos)
    local _ = {}
    if pos == nil then
        _.position = {x=(math.random() - 0.5) * globals.CONSTANTS.WORLD_SIZE, y=(math.random() - 0.5) * globals.CONSTANTS.WORLD_SIZE}
    else
        _.position = pos
    end
    setmetatable(_, Target)
    return _
end

---@class Item
---@field level number
---@field dur number

---@class Character
---@field name string
---@field hp number
---@field max_hp number
---@field hunger number
---@field tiredness number
---@field base_attack number
---@field base_defense number
---@field weapon Item
---@field armour Item
---@field potion Item
---@field position Position
---@field occupation_data number
---@field stash "food"|nil
---@field is_rat boolean
---@field had_finished_order boolean
---@field has_shop boolean
---@field order Order
---@field quest Quest|nil
---@field job_index nil|number
Character = {}
Character.__index = Character

---@param max_hp number
---@param wealth number
---@param pos Position
---@param base_attack number
---@param base_defense number
---@param is_rat boolean
---@return Character
function Character:new(max_hp, wealth, pos, base_attack, base_defense, is_rat)
    local character = {entity_type = "CHARACTER"}
    setmetatable(character, self)

    local name = ''
    for i = 0, 4 do
        name = name .. moraes[math.random(#moraes)]
    end
    character.name = name

    character.position = pos

    character.hp = max_hp
    character.max_hp = max_hp
    character.hunger = 0
    character.tiredness = 0

    character.stash = nil
    character.wealth = wealth
        
    character.weapon = {level=0, dur=100}
    character.armour = {level=0, dur=100}
    character.potion = {level=0, dur=100}

    character.base_attack = base_attack
    character.base_defense = base_defense

    character.target = nil
    character.home = nil
    character.order = "idle"

    character.rat = is_rat
    character.had_finished_order = true
    character.has_shop = false

    character.quest = nil

    character.occupation_data = 0
    character.job_index = nil

    return character
end

--- methods with __ are supposed to be fired only inside this class

---Sets a new home to a character
---@param b Building
function Character:set_home(b)
    self.home = b
end

---returns coordinate at which character is
---@return Position
function Character:pos()
    return self.position
end

---returns cell at which character is
---@return Cell
function Character:cell()
    return convert_coord_to_cell(self:pos())
end

---comment
---@return number
function Character:get_hunger()
    return self.hunger
end

---comment
---@return number
function Character:get_tiredness()
    return self.tiredness
end

function Character:get_potions_amount()
    return self.potion.level
end

function Character:get_wealth()
    return self.wealth
end


---Updates inner state of character: hunger, hp, potions
function Character:update()
    if math.random() > 0.99 then
        self:__set_hunger(self.hunger + 1)    
    end

    if self.potion.level > 0 then
        self.potion.dur = self.potion.dur - 1
        if (self.potion.dur < 0) or (self.hp < (self.max_hp / 2)) then
            self:__drink_potion()
        end
    end
end

function Character:add_wealth(x)
    self.wealth = self.wealth + x
end

---Pays x wealth to target  
---@param target Character|Building
---@param x number
function Character:pay(target, x)
    self:add_wealth(-x)
    target:add_wealth(x)
end

---shifts coordinate by (a, b) 
---@param a number
---@param b number
function Character:__shift(a, b)
    self.position.x = self.position.x + a
    self.position.y = self.position.y + b
end

---comment
---@param pos Position
function Character:__set_position(pos)
    self.position.x = pos.x
    self.position.y = pos.y
end


---comment
---@param x number
---@return any
function Character:__change_hp(x)
    self.hp = self.hp + x
    if (self.hp > self.max_hp) then
        self.hp = self.max_hp
    end
    if self.hp > 0 then
        return HP_RESPONSE.ALIVE
    else
        return HP_RESPONSE.DEAD
    end
end

function Character:__change_tiredness(x)
    self.tiredness = self.tiredness + x
    if (self.tiredness > 100) then
        self.tiredness = 100
    end
end

---comment
---@param x number
function Character:__set_hunger(x)
    self.hunger = x
end

---comment
---@return number
function Character:__dist_to_target()
    local dx, dy, norm = true_dist(self, self.target)
    return norm
end

---returns euclidian distance to target-like object
---@param x Target
---@return number
function Character:__dist_to(x)
    local dx, dy, norm = true_dist(self, x)
    return norm
end

function Character:__fast_dist_to(x)

end

---comment
---@return number
function Character:__move_to_target()
    if self.target == nil then
        return
    end
    local dx, dy, norm = true_dist(self, self.target)
    norm = norm * (1 + self.tiredness / 50)
    if math.random() > 0.98 then
        self:__change_tiredness(1)
    end    
    if (norm > 1) then
        self:__shift(dx / norm, dy / norm)
        return MOVE_RESPONSE.STILL_MOVING
    else
        self:__shift(dx, dy)
        return MOVE_RESPONSE.TARGET_REACHED
    end
end

---comment
---@param shop Building
function Character:__buy_potions(shop)
    if (self.wealth >= shop.price) and (shop.stash > 0) then
        shop.wealth_before_tax = shop.wealth_before_tax + shop.price
        shop.stash = shop.stash - 1
        self.wealth = self.wealth - shop.price
        self.potion.level = self.potion.level + 1
    end
end

---buys food from a shop and eats it
---@param shop Building
function Character:__buy_food(shop)
    if (self.wealth >= shop.buy_price) and (shop.stash > 0) then
        self:pay(shop, shop.buy_price)
        shop:update_on_buy()
        self:__eat_effect()
        return Event_ActionFinished()
    else
        return Event_ActionFailed()
    end
end

---Character attempts to sell food in shop  
---If shop has enough money then returns ActionFinished event  
---Otherwise returns ActionFailed event
---@param shop Building
---@return EventSimple
function Character:__sell_food(shop)
    if shop:get_wealth() > shop.sell_price and self.stash == "food" then
        shop:pay(self, shop.sell_price)
        shop:update_on_sell()
        shop.stash = shop.stash + 1
        self.stash = nil
        return Event_ActionFinished()
    end
    return Event_ActionFailed()
end

---Collects **taxes** from **building** into **temporary wealth** according to **tax rate**  
---which collecting **character** remembers  in **occupation_data**  
---Remaining money are sent to wealth pool which can be collected by **owner**  
---Function is supposed to be used by **tax collector**
---@param shop Building
function Character:__tax_building(shop)
    local tax = 0
    self.occupation_data = castle.INCOME_TAX
    if shop.owner == castle then
        tax = shop.wealth_before_tax[shop]
    else
        tax = math.floor(shop.wealth_before_tax[shop] * self.occupation_data / 100)
    end
    self.temp_wealth = self.temp_wealth + tax
    shop.wealth = shop.wealth + shop.wealth_before_tax - tax
    shop.wealth_before_tax = 0
end

---comment
---@param castle any
function Character:__return_tax(castle)
    castle.income(self.wealth)
    self.wealth = 0
end

---character rests  
--- until gets to `50 - quality` tiredness 
--- quality of 50 gives 3 times larger speed of rest
--- returns ActionFinished event if got to minimal tiredness
--- returns ActionInProgress if still resting
---@return EventSimple
function Character:__sleep(quality)
    local lower_bound = 50
    if quality ~= nil then
        lower_bound = math.max(0, 50 - quality)
    else
        quality = 0
    end
	if math.random() > 0.95 - quality / 5 / 100 then 
        self.tiredness = math.max(self.tiredness - 1, lower_bound)
    end
    if self.tiredness == lower_bound then
        return Event_ActionFinished()
    end
    return Event_ActionInProgress()
end


function Character:is_rat()
    if self.is_rat then
        return true
    end
    return false
end


---comment
---@param char Character
---@return number
function Character:__attack_char(char)
	self.tiredness = self.tiredness + 1
    local attack = self.base_attack + self.weapon.level
    local defense = char.base_defense + char.armour.level
    if attack > defense then
        local tmp = char.__change_hp(defense - attack)
        if tmp == HP_RESPONSE.DEAD then
            self.wealth = self.wealth + char.wealth
            char.wealth = 0
            if char.is_rat() then
                self.stash = STASH.RAT
            end
            return ATTACK_RESPONSE.KILL
        end
        return ATTACK_RESPONSE.DAMAGE
    end
    return ATTACK_RESPONSE.NO_DAMAGE
end

---comment
function Character:__drink_potion()
    if self.potion.level > 0 then
        self.potion.level = self.potion.level - 1
        self.potion.dur = 100
        self.__change_hp(30)
    end
end

---comment
---@param castle Castle
function Character:__recieve_reward(castle)
    if (self.stash == STASH.RAT) then
        if castle.reserved_hunt_budget > castle.HUNT_REWARD then
            self.wealth = self.wealth + castle.HUNT_REWARD
            castle.reserved_hunt_budget = castle.reserved_hunt_budget - castle.HUNT_REWARD
        else
            self.wealth = self.wealth + castle.reserved_hunt_budget
            castle.hunt_budget = 0
        end
    end
end


---comment
---@param building Building
function Character:__transfer_item_to_building(building)
    buildings.stash = building.stash + 1
end

---collects **after tax** money from building  
---reserved for **owner**s of building
---@param building Building
function Character:__collect_money_from_building(building)
    local tmp = building.wealth
    building.wealth = 0
    self.wealth = self.wealth + tmp
end

---returns closest food shop to character  
---in plans: make a system of "knowledge"

---comment
---@param shop_type ShopType
---@return Building|nil
function Character:__closest_shop(shop_type)
    local tmp_target = nil
    local tmp_dist = nil
    for k, v in pairs(buildings) do
        -- if v.class == shop_type then
            local tmp = self:__dist_to(v)
            if (tmp_target == nil) or (tmp_dist > tmp) then
                tmp_target = v
                tmp_dist = tmp
            end
        -- end
    end
    return tmp_target
end

---Returns closest shop to character. nil if no shop exists.
---@return Building|nil
function Character:get_closest_shop()
    return self:__closest_shop()
end

---comment
---@return Character|nil
function Character:__check_rat()
    -- for k, v in pairs(rats) do
    --     if v.is_rat() then
    --         return v
    --     end
    -- end
    return nil
end

---comment
---@return EventTargeted|nil
function Character:__check_food()
    for _, f in pairs(food) do
        if (self:__dist_to(f) < 20) and (f.cooldown == 0) then
            return Event_TargetFound(f)
        end
    end
    return nil
end

---Returns current cell as target in TargetFound event if it's far away enough from other buildings  
---Returns nil otherwise
---@return EventCell|nil
function Character:__check_space()
    local dist = self:__dist_to(castle)
    for _, f in pairs(buildings) do
        local tmp = self:__dist_to(f)
        if dist > tmp then
            dist = tmp
        end
    end
    if dist > 100 then
        return Event_CellFound(self:cell())
    end
    return nil
end

function Character:__set_random_target_circle()
    local alpha = math.random() * 2 * math.pi
    local x = self:pos().x + math.cos(alpha) * 80
    local y = self:pos().y + math.sin(alpha) * 80
    local dx, dy, norm = true_dist(self, castle)
    x = x + dx / 10
    y = y + dy / 10
    local target = Target:new({x=x , y=y})
    self:set_target(target)
end


---comment
---@param target Target|Character|Building
function Character:set_target(target)
    self.target = target
end

---@alias Order "patrol"|"attack"|"move"|"idle"|"buy_food"|

---Gives an order to a character, replacing old one
---@param order Order
function Character:set_order(order)
    self.order = order
    self.had_finished_order = false
end


function Character:set_order_Wander()
    self:set_order("wander")
    self:__set_random_target_circle()
end

function Character:set_order_WanderForFood()
    self:set_order("wander_food")
    self:__set_random_target_circle()
end

function Character:set_order_WanderForVacantSpace()
    self:set_order("wander_vacant_space")
    self:__set_random_target_circle()
end

---comment
---@return Event
function Character:execute_order()

    if self.order == "move" then -- character moves to current target
        local tmp = self:__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            self.had_finished_order = true
            return Event_ActionFinished()
        end
        return nil
    end

    if self.order == "attack" then -- character attacks current target
        dist = self.__dist_to_target()
        if dist > 1 then 
            self.__move_to_target()
        end
        if dist < 2 then
            local tmp = self.__attack_char(self.target)
            if tmp == ATTACK_RESPONSE.KILL then
                self.had_finished_order = true
                return Event_EnemyKilled:new()
            end
            return tmp
        end
        return nil
    end


    if self.order == "buy_food" then
        local tmp = self.__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            self:__buy_food(self.target)

            local event = Event_Bought()
            self.had_finished_order = true
            return event
        end
        return nil
    end


    if self.order == "find_shop" then
        local closest = self:__closest_shop()
        if closest == nil then
            return Event_ActionFailed()
        end
        self:set_target(closest)
        return Event_TargetFound(closest)
    end


    if self.order == "rest" then
		self.target = self.home
		if self:__dist_to_target() < 0.1 then
            local tmp = self:__sleep(50);
			return tmp
		else
			return Event_ActionFailed()
		end
    end

    if self.order == "rest_on_ground" then
		self.target = self.home
        local tmp = self:__sleep();
        return tmp
    end

    if self.order == "rest_at_castle" then
		self.target = castle
        if self:__dist_to_target() < 0.1 then
            local tmp = self:__sleep(50);
			return tmp
		else
			return Event_ActionFailed()
		end
    end

    
    if self.order == "wander" then  -- characters wanders around and sending events about food related things he found
        local tmp = self:__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            return Event_ActionFinished()
        end
        return Event_ActionInProgress()
    end

    --- food related actions
    if self.order == "wander_food" then  -- characters wanders around and sending events about food related things he found
        local tmp = self:__move_to_target()
        local food = self:__check_food()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            return Event_ActionFinished()
        end
        if food == nil then
            return nil
        end
        self:set_target(food.target)
        return food
    end
    if self.order == "gather_eat" then
        return self:__collect_food(self.target, "eat")
    end

    if self.order == "collect_food" then
        return self:__collect_food(self.target, "keep")
    end

    if self.order == "return_to_castle" then
        local target = castle
        self.target = target
        local tmp = self:__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            return Event_ActionFinished()
        end
        return Event_ActionInProgress()
    end

    if self.order == "return_home" then
        if self.home == nil then
            return Event_ActionFailed()
        end
        local target = self.home
        self.target = target
        local tmp = self:__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            return Event_ActionFinished()
        end
        return Event_ActionInProgress()
    end

    if self.order == "wander_vacant_space" then
        local tmp = self:__move_to_target()
        local space = self:__check_space()
        if space == nil then
            if tmp == MOVE_RESPONSE.TARGET_REACHED then
                return Event_ActionFinished()
            else
                return Event_ActionInProgress()
            end
        else
            self.target = space.target
            return space
        end
    end

    if self.order == "sell" then
        local responce = self:__sell_food(self.target)
        return responce
    end

    if self.order == "buy_eat" then
        local responce = self:__buy_food(self.target)
        return responce
    end

    if self.order == "apply" then
        return self:__apply(self.target)
    end

    if self.order == "get_paid" then
        return castle:pay_earnings(self)
    end

    if self.order == "find_tax_target" then
        return self:__find_building_to_tax()
    end

    if self.order == "tax_target" then
        return self:__tax_building(self.target)
    end

    pcall(function () error("Character " .. self.name .. " got unknown order: " .. self.order) end)
end


MIN_GOLD_TO_TAX = 20
MAX_GOLD_TO_CARRY = 100
function Character:__find_building_to_tax()
    local optimal = 0
    local final_target = nil
    for j, w in pairs(buildings) do
        local p_tax = w.wealth_before_tax
        local dist = self:__dist_to(w)
        if (p_tax > MIN_GOLD_TO_TAX) and (p_tax / dist > optimal) then
            optimal = w / dist
            final_target = w
        end
    end
    if final_target == nil then
        return Event_ActionFailed()
    end
    return Event_TargetFound(final_target)
end


---Apply for a tax collector job
---@param castle Castle
function Character:__apply(castle)
    if castle == nil then
        print("???")
        return Event_ActionFailed()
    end
    return castle:apply_for_office(self)
end

function Character:hire(tag, index)
    if tag == "tax_collector" then
        self.is_tax_collector = true
        self.job_index = index
    end
end

function Character:fire(tag)
    if tag == "tax_collector" then
        self.is_tax_collector = false
        self.job_index = nil
    end
end

---Collects food and eat it  
---Effect:  
---        restores 10 hp  
---        sets hunger to 0  
---        increases tiredness 
---@param food Target
---@param property "keep"|"eat"
---@return table
function Character:__collect_food(food, property)
    if food.cooldown > 0 then
        return Event_ActionFailed()
    end

    if property == "eat" then
        self:__eat_effect()
    end
    if property == "keep" then
        self.stash = "food"
    end

    self:__change_tiredness(1)
    self.target.cooldown = 10000

    return Event_ActionFinished()
end


function Character:__eat_effect()
    self:__change_hp(10)
    self:__set_hunger(0)
end

---comment
---@return boolean
function Character:finished()
    return self.had_finished_order
end

return Character