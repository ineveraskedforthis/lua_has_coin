local function move_action(character) 
    local tmp = character:__move_to_target()
    if tmp == MOVE_RESPONSE.TARGET_REACHED then
        return Event_ActionFinished()
    end
    return Event_ActionInProgress()
end 


local function find_shop_buy(character)
    local closest = character:__optimal_buy_shop()
    if closest == nil then
        return Event_ActionFailed()
    end
    character:set_target(closest)
    return Event_TargetFound(closest)
end

local function find_shop_sell(character)
    local closest = character:__optimal_sell_shop()
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


local function gather_eat(character)
    return character:__collect_food(character.target, "eat")
end
local function gather_keep(character)
    return character:__collect_food(character.target, "keep")
end

local function sell_food(character)
    return character:__sell_food(character.target)
end

local function buy_food_eat(character)
    return character:__buy_food(character.target)
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



OrderMove = Order:new("Move", move_action)
OrderWander = Order:new("Wander", move_action, nil, true)
OrderWanderFood = Order:new("Search for food", move_action, "food", true)
OrderWanderSpace = Order:new("Search for food", move_action, "space", true)

OrderRestHome = Order:new("Rest at home", rest_at_home)
OrderRestCastle = Order:new("Rest at castle", rest_at_castle)
OrderRestGround = Order:new("Rest on ground", rest_on_ground)

OrderFindShopBuy = Order:new("Find shop to buy", find_shop_buy)
OrderFindShopSell = Order:new("Find shop to sell", find_shop_sell)

OrderGatherEat = Order:new("Gather and eat", gather_eat)
OrderGatherKeep = Order:new("Gather and keep", gather_keep)

OrderSellFood = Order:new("Sell food", sell_food)
OrderBuyFood = Order:new("Buy food", buy_food_eat)

OrderApplyForJob = Order:new("Apply for a job", apply_for_job)
OrderGetPaid = Order:new("Get paid", get_paid)

OrderFindTaxTarget = Order:new("Find tax targer", find_building_to_tax)
OrderTaxTarget = Order:new("Tax target", tax_target)
OrderReturnTaxCastle = Order:new("Return tax to castle", return_tax_to_castle)

OrderTakeGoldFromHome = Order:new("Take gold from home", take_gold_from_home)

OrderIdle = Order:new("Idle", idle)