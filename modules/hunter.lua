-- AI for hunters:
-- logic:
-- wander around, looking for rats
-- when rat is found: attack rat
-- when rat is killed: go back for reward 

-- AI (Agent instructions) class:
-- receives event from character
-- gives order to character according to this AI and event 

-- AI object have stages, which represents what exactly agent is trying to accomplish right now
-- they could be seen as nodes of flow diagram of AI

--- utility axioms:  
--- A1: abstract need being at 100 has an utility of satifying it of 100  
--- A2: if some action/resource is lacking and required for eating/sleaping, add eating/sleaping utility to action,
---  multiplied by MONEY_DESIRE_MOD (always more than 1!)  
--- A3: Potions utility is 100 / (x + 1) where x is current amount of potions  
--- 0 -> 100, 1 -> 50, 2 -> 33 and so on  
--- money don't have inherent utility, their utility is calculated from A2  
--- after calculations utility is multiplied by zero if agent lacks resources  


---@alias PotentialTarget Target|Character|Building

---@class Hunter_AI
---@field stage "EMPTY"|"SEARCHING_FOR_RAT"|"ATTACKING_RAT"|"RETURNING_FOR_REWARD"
---@field kingdom Castle
Hunter_AI = {}
Hunter_AI.__index = Hunter_AI






-- AI have to have some internal state, because storing things like "stages" on characters themselves is a bit weird
-- because character objects represent characters as dolls, while AI is manipulating them.

---@return Hunter_AI
function Hunter_AI:new()
	_ = {stage="EMPTY"}
	setmetatable(_, Hunter_AI)
	return _
end





MONEY_DESIRE_MOD = 10


--- decides and set a new Agent Instructions.  
--- chooses action with largest possible utility  
---@param character Character
function Hunter_AI:choose_algo(character)
	local food_price = self.kingdom.FOOD_PRICE
	local sleep_price = self.kingdom.SLEEP_PRICE
	local potion_price = self.kingdom.POTION_PRICE

	local eat_utility = character:get_hunger()
	local sleep_utility = character:get_tiredness()
	local potion_utility = 100 / (character:get_potions_amount() + 1)
	local money_utility = (eat_utility + sleep_price + potion_utility) / (food_price + sleep_price + potion_price) * MONEY_DESIRE_MOD
	local hunt_utility = self.kingdom.HUNT_REWARD * money_utility

	if food_price > character:get_wealth() then eat_utility = 0 end
	if sleep_price > character:get_wealth() then sleep_utility = 0 end
	if potion_price > character:get_wealth() then potion_utility = 0 end

	local max_utility = math.max(eat_utility, sleep_utility, potion_utility, hunt_utility)

	if eat_utility == max_utility then
		self:set_stage('eat_journey_started')
		local _ = Event_ShoppingJourneyStarted:new()
		self:eat(character, _)
	end

end

function Hunter_AI:set_stage(stage)
	self.stage = stage
end

function Hunter_AI:set_kingdom(kingdom)
	self.kingdom = kingdom
end

---contains the core of **AI**  
---**character** is processing current **order** and generates **event**s during it  
---**AI** handles **event**s to issue new **order**s and set new **target**s to **character**  
---**AI** is not able to run "immediate effect" actions, only things above.
---@param character Character
---@param event Event
function Hunter_AI:hunt_algo(character, event)
	local stage = self:stage()
	if (event.type == "hunt_started") then
		self:set_stage("SEARCHING_FOR_RAT")
		character:set_order("patrol")
		return
	end
	if (stage == "SEARCHING_FOR_RAT") and (event.type == "spotted_enemy") and (event.target:is_rat()) then
		self:set_stage("ATTACKING_RAT")
		character:set_target(event.target)
		character:set_order("attack")
		return
	end
	if (stage == "ATTACKING_RAT") and (event.type == "target_killed") then
		self:set_stage("RETURNING_FOR_REWARD")
		local castle = character.quest.castle
		character:set_order("get_reward")
	end
	if (stage == "RETURNING_FOR_REWARD") and (event.type == "rewarded") then
		self:choose_algo(character)
	end
end



---generic agent instruction
---@param character Character
---@param event Event
function Hunter_AI:eat(character, event)
	local stage = self:stage()
	if (event.type == "shopping_journey_started") then
		self:set_stage("find_shop")
		character:set_order("find_food_shop")
		return
	end
	if (event.type == "food_shop_found") then
		character:set_target(event.target)
		character:set_order("buy_food")
	end
	if (event.type == "bought") then
		self:choose_algo(character)
	end
end



---generic agent instruction
---@param character Character
---@param event Event
function Hunter_AI:buy_potion(character, event)
	local stage = self:stage()
	if (event.type == "shopping_journey_started") then
		self:set_stage("find_shop")
		character:set_order("find_potion_shop")
		return
	end
	if (event.type == "potion_shop_found") then
		character:set_target(event.target)
		character:set_order("buy_potion")
	end
	if (event.type == "bought") then
		self:choose_algo(character)
	end
end


function Hunter_AI:rest(character, event)
	local stage = self:set_stage()
	if (event.type == "shopping_journey_started") then
		self:set_stage("go_home")
		character:set_order("rest")
		return
	end
	if (event.type == "rested") then
		self:choose_algo(character)
	end
end