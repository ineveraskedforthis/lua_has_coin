
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


---@class Castle




---@class Quest
---@field castle Castle
---@field reward number



---@class Position
---@field x number
---@field y number



---comment
---@param a any
---@param b any
---@return number
---@return number
---@return number
function true_dist(a, b)
    dx = a:pos().x - b:pos().x;
    dy = a:pos().y - b:pos().y;
    return dx, dy, math.sqrt(dx * dx + dy * dy)
end


---@class Target
---@field position Position
Target = {position={x=nil, y=nil}}
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
---@field is_rat boolean
---@field had_finished_order boolean
---@field order Order
---@field quest Quest|nil
Character = {}

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

    character.position = pos

    character.hp = max_hp
    character.max_hp = max_hp
    character.hunger = 0
    character.tiredness = 0

    character.stash = STASH.NONE
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

    character.quest = nil

    return character
end

--- methods with __ are supposed to be fired only inside this class

---comment
---@param b Building
function Character:set_home(b)
    self.home = b
end

---comment
---@return Position
function Character:pos()
    return self.position
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



function Character:update()
    self:__set_hunger(self.hunger + 1)
    if self.potion.level > 0 then
        self.potion.dur = self.potion.dur - 1
        if (self.potion.dur < 0) or (self.hp < (self.max_hp / 2)) then
            self:__drink_potion()
        end
    end
    return self.execute_order()
end

---comment
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

function Character:__dist_to(x)
    local dx, dy, norm = true_dist(self, x)
    return norm
end

---comment
---@return number
function Character:__move_to_target()
    if self.target == nil then
        return
    end
    local dx, dy, norm = true_dist(self, self.target)
    if (norm > 1) then
        self.__shift(dx / norm, dy / norm)
        return MOVE_RESPONSE.STILL_MOVING
    else
        self.__shift(dx, dy)
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

---comment
---@param shop Building
function Character:__buy_food(shop)
    if (self.wealth >= shop.price) and (shop.stash > 0) then
        shop.wealth_before_tax[shop] = shop.wealth_before_tax[shop] + shop.price
        self.wealth = self.wealth - shop.price
        shop.stash = shop.stash - 1
        self:__change_hp(10)
        self:__set_hunger(0)
    end
end

---collects **taxes** from **building** according to **tax rate** which collecting **character** remembers  
---remaining money are sent to wealth pool which can be collected by **owner**  
---function is supposed to be used by **tax collector**
---@param shop Building
function Character:__tax_building(shop)
    local tax = 0
    if shop.owner.entity_type == "KINGDOM" then
        tax = shop.wealth_before_tax[shop]
    else
        tax = math.floor(shop.wealth_before_tax[shop] * self.occupation_data / 100)
    end
    self.wealth = self.wealth + tax
    shop.wealth = shop.wealth_before_tax - tax
    shop.wealth_before_tax = 0
end

---comment
---@param castle any
function Character:__return_tax(castle)
    castle.income(self.wealth)
    self.wealth = 0
end

---comment
---@return "rested"|"not_rested"
function Character:__sleep()
	self.tiredness = math.max(self.tiredness - 1, 0)
    if self.tiredness == 0 then
        return 'rested'
    end
    return 'not_rested'
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
---@param j number
function Character:__collect_food(j)
    food_cooldown[j] = 10000
    self.stash = STASH.FOOD
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
---@return Building
function Character:__closest_shop(shop_type)
    local tmp_target = nil
    local tmp_dist = nil
    for k, v in pairs(buildings) do
        if v.class == shop_type then
            local tmp = self:__dist_to(v)
            if (tmp_target == nil) or (tmp_dist > tmp) then
                tmp_target = v
                tmp_dist = tmp
            end
        end
    end
    return tmp_target
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
---@param target Target|Character|Building
function Character:set_target(target)
    self.target = target
end

---@alias Order "patrol"|"attack"|"move"|"idle"|"buy_food"|

---comment
---@param order Order
function Character:set_order(order)
    self.order = order
    self.had_finished_order = false
end

---comment
---@return Event
function Character:execute_order()

    if self.order == "move" then -- character moves to current target
        local tmp = self.__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            self.had_finished_order = true
            return Event_TargetReached:new()
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

    if self.order == "find_food_shop" then
        local closest = self:__closest_shop('food')
        ---@type Event_ShopFound
        local event = Event_ShopFound:new(closest)
        self.had_finished_order = true
        return event
    end

    if self.order == "buy_food" then
        local tmp = self.__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            self:__buy_food(self.target)
            ---@type Event_Bought
            local event = Event_Bought:new()
            self.had_finished_order = true
            return event
        end
        return nil
    end


    if self.order == "patrol" then -- character wanders toward target and when it notices an enemy, it sends a notification to current AI
        local tmp = self.__move_to_target()

        local rat = self.__check_rat()
        if (rat ~= nil) then
            return Event_EnemySpotted:new(rat)
        end
        
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            return Event_RatNotFound:new()
        else
            return nil
        end

    end

    if self.order == "find_potion_shop" then
        local closest = self:__closest_shop('potion')
        self.had_finished_order = true
        return Event_ShopFound:new(closest)
    end

    if self.order == "buy_potion" then
        local tmp = self.__move_to_target()
        if tmp == MOVE_RESPONSE.TARGET_REACHED then
            self:__buy_potions(self.target)
            ---@type Event_Bought
            local event = Event_Bought:new()
            self.had_finished_order = true
            return event
        end
        return nil
    end

    if self.order == "rest" then
		self.target = self.home
		if self.__dist_to_target() < 0.1 then
            local tmp = self:__sleep();
			if tmp == "rested" then
				return Event_Rested:new()
			end
		else
			self:__move_to_target()
		end
        return nil
    end
end

---comment
---@return boolean
function Character:finished()
    return self.had_finished_order
end