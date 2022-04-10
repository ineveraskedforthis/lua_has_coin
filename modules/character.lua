
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


local moraes = {'xi', 'lo', 'mi', 'ki', 'a', 'i', 'ku'}



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

---@class TraitsList
---@field business_ambition boolean
---@field long_term_planning number --- character tries to gather resources for future needs

---@class SkillList
---@field gathering number
---@field alchemist number

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
---@field traits TraitsList
---@field skill SkillList
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
    character.progress = 0

    character.stash = nil
    character.wealth = wealth
    character.temp_wealth = 0
    character.skill = {}
    character.skill.gathering = 1
    character.skill.tool_making = 1
    character.skill.alchemist = 0
    
    
    character.traits = {}
    character.traits.business_ambition = false
    character.traits.long_term_planning = 5

    character.weapon = {level=0, dur=100}
    character.armour = {level=0, dur=100}
    character.potion = {level=0, dur=100}

    character.base_attack = base_attack
    character.base_defense = base_defense

    character.target = nil
    character.home = nil
    character.order = OrderIdle

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
    return Cell:new_from_coordinate(self.position)
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
    if math.random() > 0.995 then
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

-- ---comment
-- ---@param shop Building
-- function Character:__buy_potions(shop)
--     if (self.wealth >= shop.price) and (shop.stash > 0) then
--         shop.wealth_before_tax = shop.wealth_before_tax + shop.price
--         shop.stash = shop.stash - 1
--         self.wealth = self.wealth - shop.price
--         self.potion.level = self.potion.level + 1
--     end
-- end

---buys food from a shop and eats it
---@param shop Building
function Character:__buy_food(shop)
    if (self.wealth >= shop:get_buy_price(GOODS.FOOD)) and (shop:get_stash(GOODS.FOOD) > 0) then
        self:pay(shop, shop:get_buy_price(GOODS.FOOD))
        shop:update_on_buy(GOODS.FOOD)
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
    if shop:get_wealth() > shop:get_sell_price(GOODS.FOOD) and self.stash == "food" then
        shop:pay(self, shop:get_sell_price(GOODS.FOOD))
        shop:update_on_sell(GOODS.FOOD)
        self.stash = nil
        return Event_ActionFinished()
    end
    return Event_ActionFailed()
end

---@param shop Building
---@return EventSimple
function Character:__sell_potion(shop)
    if shop:get_wealth() > shop:get_sell_price(GOODS.FOOD) and self.potion.level > 0 then
        shop:pay(self, shop:get_sell_price(GOODS.FOOD))
        shop:update_on_sell(GOODS.FOOD)
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
        tax = shop.wealth_before_tax
    else
        tax = math.floor(shop.wealth_before_tax * self.occupation_data / 100)
    end
    self.temp_wealth = self.temp_wealth + tax
    shop.wealth = shop.wealth + shop.wealth_before_tax - tax
    shop.wealth_before_tax = 0
    return Event_ActionFinished()
end

---comment
---@param castle any
function Character:__return_tax(castle)
    castle:income(self.temp_wealth)
    self.temp_wealth = 0
    return Event_ActionFinished()
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

function Character:__optimal_sell_shop(x)
    local tmp_target = nil
    local tmp_value = nil
    for k, v in pairs(buildings) do
        -- if v.class == shop_type then
            local tmp = v:get_sell_price(x) - self:__dist_to(v)/1000
            if (tmp_target == nil) or (tmp_value < tmp) then
                tmp_target = v
                tmp_value = tmp
            end
        -- end
    end
    return tmp_target
end

function Character:__optimal_buy_shop(x)
    local tmp_target = nil
    local tmp_value = nil
    for k, v in pairs(buildings) do
        -- if v.class == shop_type then
            local tmp = v:get_buy_price(x) + self:__dist_to(v)/1000
            if (tmp_target == nil) or (tmp_value > tmp) and v:get_stash(x) > 0 then
                tmp_target = v
                tmp_value = tmp
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

function Character:get_optimal_sell_shop(x)
    return self:__optimal_sell_shop(x)
end

function Character:get_optimal_buy_shop(x)
    return self:__optimal_buy_shop(x)
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

---Gives an order to a character, replacing old one
---@param order Order
function Character:set_order(order)
    self.order = order
    order:set_up(self)
end

---executes current order and returns event generated during execution
---@return Event
function Character:execute_order()
    return self.order:execute(self)
end


---takes *x* money from building
---@param building Building
---@param x number
---@return EventSimple
function Character:__take_gold(building, x)
    if building == nil or building:get_wealth() < x then
        return Event_ActionFailed()
    end
    building:pay(self, x)
    return Event_ActionFinished()
end

MIN_GOLD_TO_TAX = 50
MAX_GOLD_TO_CARRY = 100
function Character:__find_building_to_tax()
    local optimal = 0
    local final_target = nil
    for j, w in pairs(buildings) do
        local p_tax = w.wealth_before_tax
        local dist = self:__dist_to(w)
        if (p_tax > MIN_GOLD_TO_TAX) and (p_tax / dist > optimal) then
            optimal = p_tax / dist
            final_target = w
        end
    end
    if final_target == nil then
        return Event_ActionFailed()
    end
    
    return Event_TargetFound(final_target)
end

function Character:check_for_tax_target()
    local tmp = self:__find_building_to_tax()
    return (tmp.type == "target_found")
end


---Apply for a tax collector job
---@param castle Castle
function Character:__apply(castle)
    if castle == nil then
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
---@return EventSimple
function Character:__collect_food(food, property)
    if food.cooldown > 0 then
        return Event_ActionFailed()
    end

    if self.progress < 200 then
        self.progress = self.progress + self.skill.gathering
        return Event_ActionInProgress()
    end
    self.progress = 0

    if property == "eat" then
        self:__eat_effect()
    end
    if property == "keep" then
        self.stash = "food"
    end

    self:__change_tiredness(5)
    self.target.cooldown = 10000

    return Event_ActionFinished()
end


function Character:__make_potion()
    if self.skill.alchemist == 0 then
        return Event_ActionFailed()
    end
    self.progress = self.progress + self.skill.alchemist
    if self.progress < 200 then
        return Event_ActionInProgress()
    end
    self.potion.level = self.potion.level + 1
    self.__change_tiredness(5)
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