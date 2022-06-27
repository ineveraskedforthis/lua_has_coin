

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

---comment
---@param character Character
---@return number
local function utility_eat_free(character)
	if character.skill.gathering > 0 then
		return character:get_hunger() * 0.5
	end
	return 0
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

local function utility_0(character)
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
local function wealth_0(character)
	return 0
end

---comment
---@param character Character
---@return number
local function income_sell_food(character)
	local shop = character:get_optimal_sell_shop(GOODS.FOOD)
	if (shop == nil) or (character.skill.gathering < 1) then
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

local function income_rat_hunt(character)
	if castle.hunt_wealth > castle.HUNT_REWARD then
		return castle.HUNT_REWARD
	end
	return 0
end

local function income_0(character)
	return 0
end

local function utility_50()
	return 50
end
local function utility_20()
	return 20
end

local SleepFree = 	UtilitySource:new(SleepInstruction, 			utility_sleep_free, 	wealth_0, 			income_0, 			utility_0)
local SleepPaid = 	UtilitySource:new(SleepPaidInstruction, 		utility_sleep_full, 	wealth_sleep_paid, 	income_0,			utility_50)
local EatFree =		UtilitySource:new(GatherFoodInstruction,		utility_eat_free,		wealth_0,			income_0, 			utility_0)
local EatPaid = 	UtilitySource:new(BuyEatInstruction,			utility_eat_paid, 		wealth_buy_food, 	income_0,			utility_20)
local SellFood = 	UtilitySource:new(SellFoodInstruction,			utility_0, 				wealth_0,			income_sell_food, 	utility_0)
local GetPaid =		UtilitySource:new(GetPaidInstruction, 			utility_0, 				wealth_0,			income_get_paid, 	utility_0)
local HomeMoney = 	UtilitySource:new(GetMoneyFromShopInstruction,	utility_0,				wealth_0,			income_from_home, 	utility_0)
local CollectTax = 	UtilitySource:new(CollectTaxInstruction, 		utility_work_tax,		wealth_0, 			income_0, 			utility_0)
local TakeJob =		UtilitySource:new(GetJobInstruction, 			utility_0,				wealth_0, 			income_get_job, 	utility_0)
local Wander = 		UtilitySource:new(WanderInstruction, 			utility_wander, 		wealth_0, 			income_0, 			utility_0)
local OpenShop = 	UtilitySource:new(OpenShopInstruction, 			utility_open_shop, 		wealth_open_shop,	income_0, 			utility_0)
local SellPotion = 	UtilitySource:new(SellPotionInstruction, 		utility_0, 				wealth_0, 			income_sell_potion,	utility_0)
local BuyPotion = 	UtilitySource:new(BuyPotionInstruction, 		utility_buy_potion, 	wealth_buy_potion,	income_0,			utility_20)
local MakePotion = 	UtilitySource:new(MakePotionInstruction, 		utility_make_potion,	wealth_0,			income_0,			utility_0)
local HuntRat = 	UtilitySource:new(HuntRatInstruction, 			utility_0,				wealth_0,			income_rat_hunt,	utility_0)


local sources = {SleepFree, SleepPaid, EatFree, EatPaid, SellFood, GetPaid, HomeMoney, CollectTax,
				 TakeJob, Wander, OpenShop, SellPotion, BuyPotion, MakePotion, HuntRat}


return sources