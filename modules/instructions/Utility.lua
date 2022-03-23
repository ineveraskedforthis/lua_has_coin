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


--- Description of actions
--- Sleep: 
---   sleep at the floor:                                     done
---     cost:      None
---     utility:   tiredness - 50
---   sleep at the castle:                                    not done 
---     cost:      castle.SLEEP_PRICE
---     utility:   tiredness
--- Eat:
---   find and eat raw food:                                  done
---     cost:      None
---     utility:   hunger * 0.5
--- OpenShop:
---   find an empty spot and build a shop:                    not done
---     cost:      200
---     utility:   100 if wealth > 200




---Gets character and decides for him the best current instruction
---@param character Character
---@return AgentInstruction
function MostUsefulAction(character)
    ---local food_price = castle.FOOD_PRICE
	local sleep_price = castle.SLEEP_PRICE
	---local potion_price = castle.POTION_PRICE

	local eat_utility = character:get_hunger()
	local sleep_utility = character:get_tiredness() - 50

	local max_utility = math.max(eat_utility, sleep_utility)

	if eat_utility == max_utility then
		return GatherFoodInstruction
	end
    if sleep_utility == max_utility then
        return SleepInstruction
    end
end