function init_hunter()
	-- HUNTER
	-- HUNTER SETTINGS
	HUNTER_DESIRED_AMOUNT_OF_POTIONS = 5
	HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION = -2
	HUNTER_DESITE_TO_HUNT_FOR_REWARD = 3
	HUNTER_DESITE_TO_HUNT_WITHOUT_REWARD = -3
	HUNTER_DESIRE_TO_CONTINUE_HUNT = 1
	-- HUNTER_NO_RATS_HUNT_COOLDOWN = 100
	HUNTER_TIREDNESS_THRESHOLD = 30

	-- HUNTER STATES
	CHAR_STATE.HUNTER_BUY_POTION = new_state_id()
	CHAR_STATE.HUNTER_BUY_FOOD = new_state_id()
	CHAR_STATE.HUNTER_HUNT = new_state_id()
	CHAR_STATE.HUNTER_WANDER = new_state_id()
	CHAR_STATE.HUNTER_GET_SLEEP = new_state_id()

	-- HUNTER RESPONCES
	HUNTER_RESPONCES = {}
	HUNTER_RESPONCES.ON_MY_WAY = 1
	HUNTER_RESPONCES.FOUND_TARGET = 2
	HUNTER_RESPONCES.BOUGHT_POTION = 3
	HUNTER_RESPONCES.TARGET_REACHED = 4
	HUNTER_RESPONCES.NO_RATS = 5
	HUNTER_RESPONCES.BOUGHT_FOOD = 6
	HUNTER_RESPONCES.RESTED_WELL = 7

	--HUNTER DESIRES
	HUNTER_DESIRE = {}
	HUNTER_DESIRE.POTION = 1
	HUNTER_DESIRE.FOOD = 2
	HUNTER_DESIRE.HUNT = 3
	HUNTER_DESIRE.SLEEP = 4

	HUNTER_DESIRE_CALC = {}
	HUNTER_DESIRE_CALC[HUNTER_DESIRE.POTION] = function(i)
		if (chars_wealth[i] < POTION_PRICE) then
			return 0
		end
		return -(HUNTER_DESIRED_AMOUNT_OF_POTIONS - chars_potions[i]) * HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION
	end

	HUNTER_DESIRE_CALC[HUNTER_DESIRE.FOOD] = function(i)
		if (chars_wealth[i] < FOOD_PRICE) then
			return 0
		end
		return chars_hunger[i] / 1000 - 2
	end

	HUNTER_DESIRE_CALC[HUNTER_DESIRE.HUNT] = function(i)
		local hunting_desire = HUNTER_DESITE_TO_HUNT_WITHOUT_REWARD
		if (REWARD > hunt_budget) then
			return hunting_desire
		end

		hunting_desire = HUNTER_DESITE_TO_HUNT_FOR_REWARD
			
		if chars_cooldown[i] > 0 then
			hunting_desire = hunting_desire - 1000
		end
		
		if chars_wealth[i] < 2 * POTION_PRICE then
			hunting_desire = hunting_desire + HUNTER_DESITE_TO_HUNT_FOR_REWARD * 2
		end
		
		if chars_state[i] == CHAR_STATE.HUNTER_HUNT then
			hunting_desire = hunting_desire + HUNTER_DESIRE_TO_CONTINUE_HUNT
		end
		
		return hunting_desire
	end

	HUNTER_DESIRE_CALC[HUNTER_DESIRE.SLEEP] = function(i)
		if (chars_tiredness[i] < HUNTER_TIREDNESS_THRESHOLD) then
			return 0
		end
		return 5 * chars_tiredness[i] / HUNTER_TIREDNESS_THRESHOLD
	end

	AGENT_LOGIC[CHAR_OCCUPATION.HUNTER] = function (i)
		if chars_hp[i] < 60 then
			char_drink_pot(i)
		end
		
		if chars_state[i] == nil then
			char_change_state(i, CHAR_STATE.HUNTER_WANDER)
		end
		
		
		
		local desire = {}    
		desire[HUNTER_DESIRE.POTION] = HUNTER_DESIRE_CALC[HUNTER_DESIRE.POTION](i)
		desire[HUNTER_DESIRE.FOOD] = HUNTER_DESIRE_CALC[HUNTER_DESIRE.FOOD](i)
		desire[HUNTER_DESIRE.HUNT] = HUNTER_DESIRE_CALC[HUNTER_DESIRE.HUNT](i)
		desire[HUNTER_DESIRE.SLEEP] = HUNTER_DESIRE_CALC[HUNTER_DESIRE.SLEEP](i)
		
		local max_desire = 0
		for j = 1, 4 do
			if (max_desire == 0) or (desire[max_desire] < desire[j]) then
				max_desire = j
			end
		end

		-- print(desire[1], desire[2], desire[3], desire[4])

		if desire[max_desire] < 1 then 
			char_change_state(i, CHAR_STATE.HUNTER_WANDER)
		elseif max_desire == HUNTER_DESIRE.POTION then
			char_change_state(i, CHAR_STATE.HUNTER_BUY_POTION)
		elseif max_desire == HUNTER_DESIRE.FOOD then
			char_change_state(i, CHAR_STATE.HUNTER_BUY_FOOD)
		elseif max_desire == HUNTER_DESIRE.HUNT then
			char_change_state(i, CHAR_STATE.HUNTER_HUNT)
		elseif max_desire == HUNTER_DESIRE.SLEEP then
			char_change_state(i, CHAR_STATE.HUNTER_GET_SLEEP)
		else
			char_change_state(i, CHAR_STATE.HUNTER_WANDER)
		end
		
		
		
		if chars_state[i] == CHAR_STATE.HUNTER_HUNT then
			res = HUNTER_HUNT(i)
			if res == HUNTER_RESPONCES.NO_RATS then
				char_change_state(i, CHAR_STATE.HUNTER_WANDER)
			end
		end
		if chars_state[i] == CHAR_STATE.HUNTER_WANDER then
			res = HUNTER_WANDER(i)
			if res == HUNTER_RESPONCES.TARGET_REACHED then
				chars_state_target[i] = nil
			end
		end
		if chars_state[i] == CHAR_STATE.HUNTER_BUY_POTION then
			res = HUNTER_BUY_POTION(i)
			if res == HUNTER_RESPONCES.BOUGHT_POTION then
				char_change_state(i, CHAR_STATE.HUNTER_WANDER)
			end
		end
		
		if chars_state[i] == CHAR_STATE.HUNTER_BUY_FOOD then
			res = HUNTER_BUY_FOOD(i)
			if res == HUNTER_RESPONCES.BOUGHT_FOOD then
				char_change_state(i, CHAR_STATE.HUNTER_WANDER)
			end
		end
		
		if chars_state[i] == CHAR_STATE.HUNTER_GET_SLEEP then
			res = HUNTER_GET_SLEEP(i)
			if res == HUNTER_RESPONCES.RESTED_WELL then
				char_change_state(i, CHAR_STATE.HUNTER_WANDER)
			end
		end
	end

	function HUNTER_HUNT(i)
		local closest_rat = nil
		local curr_dist = 99999
		for j, f in pairs(ALIVE_RATS) do
			if f then
				local tmp = char_dist(j, i)
				if (closest_rat == nil) or (tmp < curr_dist) then
					closest_rat = j
					curr_dist = tmp
				end
			end
		end
		if closest_rat ~= nil then
			chars_target[i].x = chars_x[closest_rat]
			chars_target[i].y = chars_y[closest_rat]
			chars_state_target[i] = closest_rat
			
			if curr_dist > 1 then 
				char_move_to_target(i)
			else
				local tmp = char_attack_char(i, closest_rat)
				if (tmp == CHAR_ATTACK_RESPONSE.KILL) then
					char_recieve_reward(i)
				end
			end
			
			chars_state_target[i] = nil
		end
		
		if (chars_state_target[i] == nil) and (closest_rat == nil) then
			return HUNTER_RESPONCES.NO_RATS
		end
	end

	function HUNTER_WANDER(i)
		if chars_state_target[i] == nil then
			chars_state_target[i] = -1
			local dice = math.random() - 0.5
			chars_target[i].x = dice * dice * dice * 400 + buildings_x(chars_home[i])
			local dice = math.random() - 0.5
			chars_target[i].y = dice * dice * dice * 400 + buildings_y(chars_home[i])
		else
			local res = char_move_to_target(i)
			if res == MOVEMENT_RESPONCES.STILL_MOVING then
				return HUNTER_RESPONCES.ON_MY_WAY
			end
			if res == MOVEMENT_RESPONCES.TARGET_REACHED then
				return HUNTER_RESPONCES.TARGET_REACHED
			end
		end
	end

	function HUNTER_GET_SLEEP(i, dt)
		if chars_state_target[i] == nil then
			local closest = chars_home[i]
			if closest ~= nil then
				chars_state_target[i] = closest
				chars_target[i].x = buildings_x(closest)
				chars_target[i].y = buildings_y(closest)
			end
		elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
			if chars_tiredness[i] == 0 then
				return HUNTER_RESPONCES.RESTED_WELL
			end
		else 
			char_move_to_target(i)
			return HUNTER_RESPONCES.ON_MY_WAY
		end
	end

	function HUNTER_BUY_POTION(i)
		if chars_state_target[i] == nil then
			local closest = find_closest_potion_shop(i)
			if closest ~= nil then
				chars_state_target[i] = closest
				chars_target[i].x = buildings_x(closest)
				chars_target[i].y = buildings_y(closest)
			end
		elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
			char_buy_potions(i, chars_state_target[i])
			return HUNTER_RESPONCES.BOUGHT_POTION
		else 
			char_move_to_target(i)
			return HUNTER_RESPONCES.ON_MY_WAY
		end
	end

	function HUNTER_BUY_FOOD(i)
		if chars_state_target[i] == nil then
			local closest = find_closest_food_shop(i)
			if closest ~= nil then
				chars_state_target[i] = closest
				chars_target[i].x = buildings_x(closest)
				chars_target[i].y = buildings_y(closest)
			end
		elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
			char_buy_food(i, chars_state_target[i])
			return HUNTER_RESPONCES.BOUGHT_FOOD
		else 
			char_move_to_target(i)
			return HUNTER_RESPONCES.ON_MY_WAY
		end
	end
end