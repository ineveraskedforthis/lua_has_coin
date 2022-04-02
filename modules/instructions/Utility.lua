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


--- Description of actions
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
---     utility:   hunger * 0.5
--- OpenShop:
---   find an empty spot and build a shop:                    done
---     cost:      200 money into building's bank
---     utility:   200 if wealth > 200 and no shop yet
--- Wander:
---	  walk around doing nothing:
---		cost:      None
---		utility:   30



---Gets character and decides for him the best current instruction
---@param character Character
---@return AgentInstruction
function MostUsefulAction(character)
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

	local max_utility = math.max(eat_utility, sleep_utility, open_shop_utility, sleep_paid_utility, sell_food_utility, wander_utility)
	if eat_utility == max_utility then
		return GatherFoodInstruction
	end
    if sleep_utility == max_utility then
        return SleepInstruction
    end
	if open_shop_utility == max_utility then
		return OpenShopInstruction
	end
	if sleep_paid_utility == max_utility then
		return SleepPaidInstruction
	end
	if sell_food_utility == max_utility then
		return SellFoodInstruction
	end
	if eat_paid_utility == max_utility then
		return BuyEatInstruction
	end
	if wander_utility == max_utility then
		return WanderInstruction
	end
end

function Calculate_Utility(character)
	---local food_price = castle.FOOD_PRICE
	local sleep_price = castle.SLEEP_PRICE
	---local potion_price = castle.POTION_PRICE

	local money_utility_total = 0
	local money_required_total = 0
	local money_utility_per_unit = 0

	local eat_utility = character:get_hunger()
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

	if money_required_total ~= 0 then
		money_utility_per_unit = money_utility_total / money_required_total
	end

	local shop = character:get_closest_shop()
	local sell_food_utility = 0
	if (shop ~= nil) and (shop:get_wealth() >= shop.sell_price) then
		sell_food_utility = money_utility_per_unit * shop.sell_price
	end	

	local wander_utility = 30

	return {eat_utility, sleep_utility, open_shop_utility, sleep_paid_utility, sell_food_utility, wander_utility}
end