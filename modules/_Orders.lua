local function move_action(character) 
    local tmp = character:__move_to_target()
    if tmp == MOVE_RESPONSE.TARGET_REACHED then
        return Event_ActionFinished()
    end
    return Event_ActionInProgress()
end 


local function find_shop_buy_food(character)
    local closest = character:__optimal_buy_shop(GOODS.FOOD)
    if closest == nil then
        return Event_ActionFailed()
    end
    character:set_target(closest)
    return Event_TargetFound(closest)
end

local function find_shop_sell_food(character)
    local closest = character:__optimal_sell_shop(GOODS.FOOD)
    if closest == nil then
        return Event_ActionFailed()
    end
    character:set_target(closest)
    return Event_TargetFound(closest)
end

local function find_shop_buy_potion(character)
    local closest = character:__optimal_buy_shop(GOODS.POTION)
    if closest == nil then
        return Event_ActionFailed()
    end
    character:set_target(closest)
    return Event_TargetFound(closest)
end

local function find_shop_sell_potion(character)
    local closest = character:__optimal_sell_shop(GOODS.POTION)
    -- print(closest)
    if closest == nil then
        return Event_ActionFailed()
    end
    character:set_target(closest)
    return Event_TargetFound(closest)
end

local function rest_at_home(character)
    character.target = character.home
    if character:__dist_to_target() < 0.1 then
        local tmp = character:__sleep(50);
        return tmp
    else
        return Event_ActionFailed()
    end
end

---comment
---@param character Character
---@return EventSimple
local function rest_on_ground(character)
    character.target = character.home
    local tmp = character:__sleep();
    return tmp
end

---rest at castle
---@param character Character
---@return EventSimple
local function rest_at_castle(character)
    character.target = castle
    if character:__dist_to_target() < 0.1 then
        local tmp = character:__sleep(50);
        return tmp
    end
    return Event_ActionFailed()
end

---comment
---@param character Character
---@return EventSimple
local function gather_eat(character)
    return character:__collect_food(character.target, "eat")
end
local function gather_keep(character)
    return character:__collect_food(character.target, "keep")
end

---forces character to make potion
---@param character Character
---@return EventSimple
local function make_potion(character)
    return character:__make_potion()
end

local function sell_food(character)
    return character:__sell_food(character.target)
end

local function buy_food_eat(character)
    return character:__buy_food(character.target)
end
local function sell_potion(character)
    return character:__sell_potion(character.target)
end
---comment
---@param character Character
---@return EventSimple
local function buy_potion(character)
    return character:__buy_potion(character.target)
end

local function apply_for_job(character)
    return character:__apply(character.target)
end
local function get_paid(character)
    return castle:pay_earnings(character)
end

local function find_building_to_tax(character)
    local tmp = character:__find_building_to_tax()
    if tmp.target == nil then
        return tmp
    end
    character:set_target(tmp.target)
    return tmp
end

local function tax_target(character)
    return character:__tax_building(character.target)
end
local function return_tax_to_castle(character)
    return character:__return_tax(castle)
end
local function take_gold_from_home(character)
    return character:__take_gold(character.home, 50)
end

local function idle(character)
    return Event_ActionFinished()
end

---comment
---@param character Character
---@return EventSimple
local function claim_reward(character)
    return character:claim_reward(castle)
end

---comment
---@param character Character
---@return EventSimple
local function get_reward(character)
    return character:get_reward(castle)
end

local function attack_target(character)
    return character:__attack_target()
end


Orders = {}


Orders.Move = {}
Orders.Move.Target = Order:new("Move", move_action)


Orders.Wander = {}
Orders.Wander.Nothing = Order:new("Wander", move_action, nil, true)
Orders.Wander.Food = Order:new("Search for food", move_action, "food", true)
Orders.Wander.Space = Order:new("Search for food", move_action, "space", true)
Orders.Wander.Rat = Order:new("Search for rat", move_action, "rat", true)

Orders.Rest = {}
Orders.Rest.Home = Order:new("Rest at home", rest_at_home)
Orders.Rest.Castle = Order:new("Rest at castle", rest_at_castle)
Orders.Rest.Ground = Order:new("Rest on ground", rest_on_ground)


Orders.Find = {}
Orders.Find.ShopBuyFood = Order:new("Find shop to buy", find_shop_buy_food)
Orders.Find.ShopSellFood = Order:new("Find shop to sell", find_shop_sell_food)
Orders.Find.ShopBuyPotion = Order:new("Find shop to buy", find_shop_buy_potion)
Orders.Find.ShopSellPotion = Order:new("Find shop to sell", find_shop_sell_potion)
Orders.Find.TaxTarget = Order:new("Find tax targer", find_building_to_tax)


Orders.Gather = {}
Orders.Gather.Eat = Order:new("Gather and eat", gather_eat)
Orders.Gather.Keep = Order:new("Gather and keep", gather_keep)


Orders.Sell = {}
Orders.Buy = {}
Orders.Sell.Food = Order:new("Sell food", sell_food)
Orders.Buy.Food = Order:new("Buy food", buy_food_eat)
Orders.Sell.Potion = Order:new("Sell food", sell_potion)
Orders.Buy.Potion = Order:new("Buy food", buy_potion)


Orders.Money = {}
Orders.Money.TaxTarget = Order:new("Tax target", tax_target)
Orders.Money.TaxToCastle = Order:new("Return tax to castle", return_tax_to_castle)
Orders.Money.GetFromHome = Order:new("Take gold from home", take_gold_from_home)
Orders.Money.GetPayment = Order:new("Get paid", get_paid)
Orders.Money.GetReward = Order:new("Get quest reward", get_reward)
Orders.Money.ClaimReward = Order:new("Claim quest", claim_reward)


Orders.Apply = {}
Orders.Apply.TaxCollector = Order:new("Apply for a job", apply_for_job)

Order.Attack = {}
Order.Attack.Target = Order:new("Attack", attack_target)


Orders.Make = {}
Orders.Make.Potion = Order:new("Making potion", make_potion)


Orders.Idle = Order:new("Idle", idle)
