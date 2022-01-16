function init_food_collector()
	-- FOOD_COLLECTOR
	---- food collector is an agent that goes to food that randomly grows around the map,  +
	---- collects it and sells it in his shop, which he sets up not far from the castle +
	---- during collection, he could hurt himself, so he is carrying a bit of potions with him -
	---- he can carry only one food item in hands +
	---- one food item restores full hp and removes hunger but can't be carried like a potion
	---- so other agents should prioritise eating to using potions, if they are not engaged in other activities 
	---- income: selling food 
	---- expenses: potions, taxes



	CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP = new_state_id()
	CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD = new_state_id()
	CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD = new_state_id()
	CHAR_STATE.FOOD_COLLECTOR_FIND_FOOD = new_state_id()
	CHAR_STATE.FOOD_COLLECTOR_BUY_POTION = new_state_id()
	CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP = new_state_id()


	FOOD_COLLECTOR_RESPONCES = {}
	FOOD_COLLECTOR_RESPONCES.GOT_FOOD = 1
	FOOD_COLLECTOR_RESPONCES.AT_HOME = 2
	FOOD_COLLECTOR_RESPONCES.NO_FOOD_AROUND = 3
	FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT = 4

	--FOOD_COLLECTOR DESIRES
	FOOD_COLLECTOR_POTIONS_TARGET = 2
	FOOD_COLLECTOR_DESIRE_TO_BUY_POTION_PER_MISSING_UNIT = 1
	FOOD_COLLECTOR_FOOD_TARGET = 10
	FOOD_COLLECTOR_DESIRE_TO_COLLECT_FOOD_PER_MISSING_UNIT = 1
	FOOD_COLLECTOR_DESIRE_TO_CONTINUE_COLLECT_FOOD = 5

	FOOD_COLLECTOR_DESIRE = {}
	FOOD_COLLECTOR_DESIRE.POTION = 11
	FOOD_COLLECTOR_DESIRE.FOOD = 12
	FOOD_COLLECTOR_DESIRE.COLLECT_FOOD = 13


	DESIRE_CALC = {}
	DESIRE_CALC[FOOD_COLLECTOR_DESIRE.POTION] = function(i)
		if (chars_wealth[i] < POTION_PRICE) then
			return 0
		end
		return (FOOD_COLLECTOR_POTIONS_TARGET - chars_potions[i]) * FOOD_COLLECTOR_DESIRE_TO_BUY_POTION_PER_MISSING_UNIT
	end

	DESIRE_CALC[FOOD_COLLECTOR_DESIRE.FOOD] = function(i)
		return chars_hunger[i] / 1000 - 2
	end

	DESIRE_CALC[FOOD_COLLECTOR_DESIRE.COLLECT_FOOD] = function(i)
		local home = chars_home[i]
		local tmp = 0
		if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD then
			tmp = FOOD_COLLECTOR_DESIRE_TO_CONTINUE_COLLECT_FOOD
		end
		
		return tmp + (FOOD_COLLECTOR_FOOD_TARGET - buildings_stash[home]) * FOOD_COLLECTOR_DESIRE_TO_BUY_POTION_PER_MISSING_UNIT
	end



	AGENT_LOGIC[CHAR_OCCUPATION.FOOD_COLLECTOR] = function (i)
		if chars_hp[i] < 60 then
			char_drink_pot(i)
		end
		if chars_state[i] == nil then
			chars_state[i] = CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP
		end  
		
		if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP then
			local x, y = get_new_building_location()
			local bid = new_building(BUILDING_TYPES.FOOD_SHOP, x, y)
			char_set_home(i, bid)
			char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
		end


		if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP then
			local desire = {}
			desire[FOOD_COLLECTOR_DESIRE.POTION] = DESIRE_CALC[FOOD_COLLECTOR_DESIRE.POTION](i)
			desire[FOOD_COLLECTOR_DESIRE.FOOD] = DESIRE_CALC[FOOD_COLLECTOR_DESIRE.FOOD](i)
			desire[FOOD_COLLECTOR_DESIRE.COLLECT_FOOD] = DESIRE_CALC[FOOD_COLLECTOR_DESIRE.COLLECT_FOOD](i)
			
			local max_desire = 0
			for j = 11, 13 do
				if (max_desire == 0) or (desire[max_desire] < desire[j]) then
					max_desire = j
				end
			end

			if desire[max_desire] < 1 then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP)
			elseif max_desire == FOOD_COLLECTOR_DESIRE.POTION then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_BUY_POTION)
			elseif max_desire == FOOD_COLLECTOR_DESIRE.FOOD then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_FIND_FOOD)
			elseif max_desire == FOOD_COLLECTOR_DESIRE.COLLECT_FOOD then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
			else
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP)
			end
			
			if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP then
				local res = FOOD_COLLECTOR_STAY_IN_SHOP(i)
				if res == FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT then
					char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
				end
			end
		end
		
		if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD then
			local res = FOOD_COLLECTOR_COLLECT_FOOD(i)
			if res == FOOD_COLLECTOR_RESPONCES.GOT_FOOD then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD)
			end
		elseif chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD then
			local res = FOOD_COLLECTOR_RETURN_FOOD(i)
			if res == FOOD_COLLECTOR_RESPONCES.AT_HOME then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP)
			end
		elseif chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_BUY_POTION then
			local res = FOOD_COLLECTOR_BUY_POTION(i)
			if res == HUNTER_RESPONCES.BOUGHT_POTION then
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP)
			end
		elseif chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_FIND_FOOD then
			local res = FOOD_COLLECTOR_COLLECT_FOOD(i)
			if res == FOOD_COLLECTOR_RESPONCES.GOT_FOOD then
				chars_hunger[i] = 0
				char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_STAY_IN_SHOP)
			end

		end
	end

	function FOOD_COLLECTOR_COLLECT_FOOD(i)
		if chars_state_target[i] == nil then
			local optimal_dist = 0
			local optimal_food = nil
			local x = chars_x[i]
			local y = chars_y[i]
			for f, pos in ipairs(food_pos) do
				local p_x = pos.x * grid_size + grid_size/2
				local p_y = pos.y * grid_size + grid_size/2
				local dist = dist(x, y, p_x, p_y)
				if ((optimal_food == nil) or (optimal_dist > dist)) and (food_cooldown[f] == 0) then
					optimal_food = f
					optimal_dist = dist                
				end
			end
			
			if optimal_food == nil then
				return FOOD_COLLECTOR_RESPONCES.NO_FOOD_AROUND
			end
			
			chars_state_target[i] = optimal_food
			chars_target[i].x = food_pos[optimal_food].x * grid_size + grid_size/2
			chars_target[i].y = food_pos[optimal_food].y * grid_size + grid_size/2
		else 
			local res = char_move_to_target(i)
			if res == MOVEMENT_RESPONCES.TARGET_REACHED then
				char_collect_food(i, chars_state_target[i])
				return FOOD_COLLECTOR_RESPONCES.GOT_FOOD
			end
		end
	end

	function FOOD_COLLECTOR_RETURN_FOOD(i)
		local home = chars_home[i]
		if chars_state_target[i] == nil then
			chars_state_target[i] = home
			chars_target[i].x = buildings_x(home)
			chars_target[i].y = buildings_y(home)
		else 
			local res = char_move_to_target(i)
			if res == MOVEMENT_RESPONCES.TARGET_REACHED then
				char_transfer_item_building(i, home)
				char_collect_money_from_building(i, home)
				return FOOD_COLLECTOR_RESPONCES.AT_HOME
			end
		end
	end

	function FOOD_COLLECTOR_STAY_IN_SHOP(i)
		local home = chars_home[i]
		if chars_state_target[i] == nil then
			chars_state_target[i] = home
			chars_target[i].x = buildings_x(home)
			chars_target[i].y = buildings_y(home)
		else 
			local res = char_move_to_target(i)
			if res == MOVEMENT_RESPONCES.TARGET_REACHED then
				char_collect_money_from_building(i, home)
				if buildings_stash[home] == 0 then
					return FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT
				end
			end
		end
	end

	function FOOD_COLLECTOR_BUY_POTION(i)
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
end