--- My utility axioms:
--- A0:
---     action can satisfy X of need          ->    X utility
--- A1
---     action is unavailable due costs       ->    multiply utility by zero
--- A2: 
---     action can provide X utility          ->    add X utility to lacking resources costs of an action if any
--- A3: 
---     have X potions                        ->    50 / (x + 1) utility of next potion 
---          0, 1, 2...                       ->    50, 25, 13...
--- A4: 
---     money don't have inherent utility
--- A5: 
---		opening a business has utility 200 in case of not having a shop yet and having "enough" gold
---     otherwise, utility is -100
--- A6:
---		there is always a harmless action with at least 0 utility (to avoid choosing actions with negative utility)
--- A7:
---     between action with no cost and some cost but with same utility character chooses action with no cost
--- A8:
---		applying for a royal job has Payment * 10 utility

--- Description of actions
--- Sell 													  done
---     cost: none
---     utility: price * money_utility
--- Sleep:
---   sleep at the floor:                                     done
---     cost:      None
---     utility:   tiredness - 50
---   sleep at home:									      done
---     cost:      None
---     utility:   tiredness
---   sleep at the castle:                                    done 
---     cost:      castle.SLEEP_PRICE
---     utility:   tiredness
--- Eat:
---   find and eat raw food:                                  done
---     cost:      None
---     utility:   hunger * 0.2
---   buy and eat											  done
---     cost:      price
---     utility:   hunger
--- OpenShop:
---   find an empty spot and build a shop:                    done
---     cost:      200 money into building's bank
---     utility:   200 if wealth > 200 and no shop yet
--- Wander:
---	  walk around doing nothing:							  done
---		cost:      None
---		utility:   30
--- Apply to job:
---   apply for a royal job:
---		cost:	   None
---     utility:   payment * 10 * money_utility 




---@class UtilitySource
---@field instruction AgentInstruction
---@field utility function
---@field required_wealth function
---@field wealth_income function
UtilitySource = {}
UtilitySource.__index = UtilitySource
function UtilitySource:new(instruction, utility, required_wealth, wealth_income)
	_ = {}
	_.instruction = instruction
	_.utility = utility
	_.required_wealth = required_wealth
	_.wealth_income = wealth_income
	setmetatable(_, UtilitySource)
	return _
end

local function utility_sleep_half(character)
	return character:get_tiredness() - 50
end
local function utility_sleep_full(character)
	return character:get_tiredness()
end
local function utility_sleep_free(character)
	if character.home == nil then
		return utility_sleep_half(character)
	end
	return utility_sleep_full(character)
end

local function utility_open_shop(character)
	if (character.wealth > 200) and (character.has_shop == false) then
		return 200
	end
	return -100
end

local function utility_eat_free(character)
	return character:get_hunger() * 0.5
end

local function utility_eat_paid(character)
	local shop = character:get_closest_shop()
	if (shop ~= nil) and (shop.stash > 0) then
		return character:get_hunger()	
	end
	return 0
end

local function utility_wander(character)
	return 10
end

local function utility_work_tax(character)
	if character.is_tax_collector then
		local temp = character:check_for_tax_target()
		if temp then
			return 50
		end
	end
	return 0
end

local function utility_zero(character)
	return 0
end

local function wealth_open_shop(character)
	return 200
end

local function wealth_sleep_paid(character)
	return castle.SLEEP_PRICE
end
local function wealth_buy_food(character)
	local shop = character:get_closest_shop()
	if shop == nil then
		return nil
	end
	return shop.buy_price
end
local function wealth_none(character)
	return 0
end

local function income_sell_food(character)
	local shop = character:get_closest_shop()
	if shop == nil then
		return 0
	end
	return shop.sell_price
end
local function income_get_paid(character)
	if character.is_tax_collector and castle:payment_ready(character) then
		return castle.tax_collection_reward
	end
	return 0
end
local function income_from_home(character)
	if character.home == nil then
		return 0
	end
	if character.home:get_wealth() > 200 then
		return 50
	end
	return 0
end
local function income_get_job(character)
	if character.is_tax_collector or not castle:has_vacant_job() then
		return 0
	end
	return castle.tax_collection_reward * 10
end
local function income_none(character)
	return 0
end

local SleepFree = 	UtilitySource:new(SleepInstruction, 			utility_sleep_free, 	wealth_none, 		income_none)
local SleepPaid = 	UtilitySource:new(SleepPaidInstruction, 		utility_sleep_full, 	wealth_sleep_paid, 	income_none)
local EatFree =		UtilitySource:new(GatherFoodInstruction,		utility_eat_free,		wealth_none,		income_none)
local EatPaid = 	UtilitySource:new(BuyEatInstruction,			utility_eat_paid, 		wealth_buy_food, 	income_none)
local SellFood = 	UtilitySource:new(SellFoodInstruction,			utility_zero, 			wealth_none,		income_sell_food)
local GetPaid =		UtilitySource:new(GetPaidInstruction, 			utility_zero, 			wealth_none,		income_get_paid)
local HomeMoney = 	UtilitySource:new(GetMoneyFromShopInstruction,	utility_zero,			wealth_none,		income_from_home)
local CollectTax = 	UtilitySource:new(CollectTaxInstruction, 		utility_work_tax,		wealth_none, 		income_none)
local TakeJob =		UtilitySource:new(GetJobInstruction, 			utility_zero,			wealth_none, 		income_get_job)
local Wander = 		UtilitySource:new(WanderInstruction, 			utility_wander, 		wealth_none, 		income_none)
local OpenShop = 	UtilitySource:new(OpenShopInstruction, 			utility_open_shop, 		wealth_none,		income_none)

local sources = {SleepFree, SleepPaid, EatFree, EatPaid, SellFood, GetPaid, HomeMoney, CollectTax,
				 TakeJob, Wander, OpenShop}

---Gets character and decides for him the best current instruction
---@param character Character
---@return AgentInstruction
function MostUsefulAction(character)
	local raw_utility = {}
	local money_utility_total = 0
	local money_required_total = 0
	local money_utility_per_unit = 0
	for _, source in pairs(sources) do
		local temp_utility = source.utility(character)
		local temp_wealth = source.required_wealth(character)
		if temp_wealth == nil then
			--- it means that this thing is unavailable
		elseif temp_wealth > character:get_wealth() then
			money_utility_total = money_utility_total + temp_utility
			money_required_total = money_required_total + temp_wealth
		else
			raw_utility[_] = temp_utility
		end
	end
	if money_required_total ~= 0 then
		money_utility_per_unit = money_utility_total / money_required_total
	end
	local true_utility = {}
	for ind, _ in pairs(raw_utility) do
		local source = sources[ind]
		local income = source.wealth_income(character)
		true_utility[ind] = _ + income * money_utility_per_unit
	end
	local optimal = nil
	for k, v in pairs(true_utility) do
		if optimal == nil or true_utility[optimal] < v then
			optimal = k
		end
	end
	
	return sources[optimal].instruction
end

function Calculate_Utility(character)
    ---local food_price = castle.FOOD_PRICE
	local sleep_price = castle.SLEEP_PRICE
	local shop = character:get_closest_shop()
	---local potion_price = castle.POTION_PRICE

	local money_utility_total = 0
	local money_required_total = 0
	local money_utility_per_unit = 0

	local eat_utility = character:get_hunger() * 0.5
	local sleep_utility = character:get_tiredness()
	if character.home == nil then
		sleep_utility = character:get_tiredness() - 50
	end

	local open_shop_utility = -100
	if (character.wealth > 200) and (character.has_shop == false) then
		open_shop_utility = 200
	end

	local sleep_paid_utility = character:get_tiredness()
	if character.wealth < castle.SLEEP_PRICE then
		money_required_total = money_required_total + castle.SLEEP_PRICE
		money_utility_total = money_utility_total + sleep_paid_utility
		sleep_paid_utility = 0
	end

	local eat_paid_utility = character:get_hunger()
	if (shop == nil) or (shop.stash == 0) then
		eat_paid_utility = 0
	end
	if (shop ~= nil) and (character.wealth < shop.buy_price) and (shop.stash > 0) then
		money_required_total = money_required_total + shop.buy_price
		money_utility_total = money_utility_total + eat_paid_utility
		eat_paid_utility = 0
	end



	if money_required_total ~= 0 then
		money_utility_per_unit = money_utility_total / money_required_total
	end

	
	local sell_food_utility = 0
	if (shop ~= nil) and (shop:get_wealth() >= shop.sell_price) then
		sell_food_utility = money_utility_per_unit * shop.sell_price
	end	

	local wander_utility = 30

	return {eat_utility, sleep_utility, open_shop_utility, sleep_paid_utility, eat_paid_utility, sell_food_utility, wander_utility}
end