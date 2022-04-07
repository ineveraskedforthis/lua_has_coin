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