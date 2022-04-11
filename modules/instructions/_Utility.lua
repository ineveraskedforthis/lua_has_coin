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
---@field long_term_utility function
---@field required_wealth function
---@field wealth_income function
UtilitySource = {}
UtilitySource.__index = UtilitySource
function UtilitySource:new(instruction, utility, required_wealth, wealth_income, long_term_utility)
	_ = {}
	_.instruction = instruction
	_.utility = utility
	_.long_term_utility = long_term_utility
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


---comment
---@param character Character
---@return number
local function utility_open_shop(character)
	if (character.traits.business_ambition) and (character.has_shop == false) then
		return 400
	end
	return 0
end

local function utility_eat_free(character)
	return character:get_hunger() * 0.5
end

local function utility_eat_paid(character)
	local shop = character:get_optimal_buy_shop(GOODS.FOOD)
	if (shop ~= nil) and (shop:get_stash(GOODS.FOOD) > 0) then
		return character:get_hunger()
	end
	return 0
end

---comment
---@param character Character
---@return number
local function utility_buy_potion(character)
	if character.skill.alchemist > 0 then
		return 0
	end
	local shop = character:get_optimal_buy_shop(GOODS.POTION)
	if (shop ~= nil) and (shop:get_stash(GOODS.POTION) > 0) then
		return 50 / (character.potion.level + 1)
	end
	return 0
end 

---comment
---@param character Character
---@return number
local function utility_make_potion(character)
	if character.skill.alchemist == 0 then
		return 0
	end
	return 50 / (character.potion.level + 1)
end 

local function utility_wander(character)
	return 20
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
	local shop = character:get_optimal_buy_shop(GOODS.FOOD)
	if shop == nil then
		return nil
	end
	return shop:get_buy_price(GOODS.FOOD)
end
local function wealth_buy_potion(character)
	local shop = character:get_optimal_buy_shop(GOODS.POTION)
	if shop == nil then
		return nil
	end
	return shop:get_buy_price(GOODS.POTION)
end
local function wealth_none(character)
	return 0
end

---comment
---@param character Character
---@return number
local function income_sell_food(character)
	local shop = character:get_optimal_sell_shop(GOODS.FOOD)
	if shop == nil then
		return 0
	end
	return shop:get_sell_price(GOODS.FOOD)
end
local function income_sell_potion(character)
	if character.skill.alchemist == 0 then
		return 0
	end
	local shop = character:get_optimal_sell_shop(GOODS.POTION)
	if shop == nil then
		return 0
	end
	return shop:get_sell_price(GOODS.POTION)
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

local function utility_50()
	return 50
end
local function utility_20()
	return 20
end

local SleepFree = 	UtilitySource:new(SleepInstruction, 			utility_sleep_free, 	wealth_none, 		income_none, 		utility_zero)
local SleepPaid = 	UtilitySource:new(SleepPaidInstruction, 		utility_sleep_full, 	wealth_sleep_paid, 	income_none,		utility_50)
local EatFree =		UtilitySource:new(GatherFoodInstruction,		utility_eat_free,		wealth_none,		income_none, 		utility_zero)
local EatPaid = 	UtilitySource:new(BuyEatInstruction,			utility_eat_paid, 		wealth_buy_food, 	income_none,		utility_20)
local SellFood = 	UtilitySource:new(SellFoodInstruction,			utility_zero, 			wealth_none,		income_sell_food, 	utility_zero)
local GetPaid =		UtilitySource:new(GetPaidInstruction, 			utility_zero, 			wealth_none,		income_get_paid, 	utility_zero)
local HomeMoney = 	UtilitySource:new(GetMoneyFromShopInstruction,	utility_zero,			wealth_none,		income_from_home, 	utility_zero)
local CollectTax = 	UtilitySource:new(CollectTaxInstruction, 		utility_work_tax,		wealth_none, 		income_none, 		utility_zero)
local TakeJob =		UtilitySource:new(GetJobInstruction, 			utility_zero,			wealth_none, 		income_get_job, 	utility_zero)
local Wander = 		UtilitySource:new(WanderInstruction, 			utility_wander, 		wealth_none, 		income_none, 		utility_zero)
local OpenShop = 	UtilitySource:new(OpenShopInstruction, 			utility_open_shop, 		wealth_open_shop,	income_none, 		utility_zero)
local SellPotion = 	UtilitySource:new(SellPotionInstruction, 		utility_zero, 			wealth_none, 		income_sell_potion,	utility_zero)
local BuyPotion = 	UtilitySource:new(BuyPotionInstruction, 		utility_buy_potion, 	wealth_buy_potion,	income_none,		utility_20)
local MakePotion = 	UtilitySource:new(MakePotionInstruction, 		utility_make_potion,	wealth_none,		income_none,		utility_zero)

local sources = {SleepFree, SleepPaid, EatFree, EatPaid, SellFood, GetPaid, HomeMoney, CollectTax,
				 TakeJob, Wander, OpenShop, SellPotion, BuyPotion, MakePotion}

---Gets character and decides for him the best current instruction
---@param character Character
---@return AgentInstruction
function MostUsefulAction(character)
	local raw_utility = {}
	local price = {}
	local money_utility_total = 0
	local money_required_total = 0
	local money_earning_utility = 0
	for _, source in pairs(sources) do
		local temp_utility = source.utility(character) 
		local temp_wealth = source.required_wealth(character)
		if temp_wealth == nil then
			--- it means that this thing is unavailable
		elseif temp_wealth > character:get_wealth() then
			if temp_wealth ~= 0 then
				money_earning_utility = math.max(
					money_earning_utility,
					(temp_utility))
			end
			price[_]  = temp_wealth
		else
			raw_utility[_] = temp_utility
			price[_]  = temp_wealth
		end

		if (temp_wealth ~= nil) then
			local long_term_temp_wealth = temp_wealth * character.traits.long_term_planning
			local long_term_temp_utility = (temp_utility + source.long_term_utility(character) * character.traits.long_term_planning)
			if (long_term_temp_wealth > character:get_wealth()) then
				if temp_wealth ~= 0 then
					money_earning_utility = math.max(
						money_earning_utility,
						math.floor(long_term_temp_utility * character:get_wealth() / long_term_temp_wealth))
				end
			end
		end 
	end

	local true_utility = {}
	for ind, _ in pairs(raw_utility) do
		local source = sources[ind]
		local income = source.wealth_income(character)
		if income > 0 then
			true_utility[ind] = _ + (income - price[ind]) + money_earning_utility 
		else
			true_utility[ind] = _ + (income - price[ind])
		end
	end

	local optimal = nil
	for k, v in pairs(true_utility) do
		-- print(v)
		if optimal == nil or true_utility[optimal] < v then
			optimal = k
		end
	end	
	
	-- print(optimal)
	-- print(sources[optimal])
	return sources[optimal].instruction
end

function Calculate_Utility(character)
	local raw_utility = {}
	local price = {}
	local money_utility_total = 0
	local money_required_total = 0
	local money_earning_utility = 0
	for _, source in pairs(sources) do
		local temp_utility = source.utility(character) 
		local temp_wealth = source.required_wealth(character)
		if temp_wealth == nil then
			--- it means that this thing is unavailable
		elseif temp_wealth > character:get_wealth() then
			if temp_wealth ~= 0 then
				money_earning_utility = math.max(
					money_earning_utility,
					(temp_utility))
			end
			price[_]  = temp_wealth
		else
			raw_utility[_] = temp_utility
			price[_]  = temp_wealth
		end

		if (temp_wealth ~= nil) then
			local long_term_temp_wealth = temp_wealth * character.traits.long_term_planning
			local long_term_temp_utility = (temp_utility + source.long_term_utility(character) * character.traits.long_term_planning)
			if (long_term_temp_wealth > character:get_wealth()) then
				if temp_wealth ~= 0 then
					money_earning_utility = math.max(
						money_earning_utility,
						math.floor(long_term_temp_utility * character:get_wealth() / long_term_temp_wealth))
				end
			end
		end 
	end
	return money_earning_utility
end