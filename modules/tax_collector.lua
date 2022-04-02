function init_tax_collector()

	-- TAX COLLECTOR

	-- TAX COLLECTOR SETTINGS


	-- TAX_COLLECTOR STATES
	CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES = new_state_id()
	CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES = new_state_id()
	CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE = new_state_id()

	-- TAX COLLECTOR RESPONCES
	TAX_COLLECTOR_RESPONCES = {}
	TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS = 1
	TAX_COLLECTOR_RESPONCES.FOUND_TARGET = 2
	TAX_COLLECTOR_RESPONCES.ON_MY_WAY = 3
	TAX_COLLECTOR_RESPONCES.IN_CASTLE = 4
	TAX_COLLECTOR_RESPONCES.GOT_TAX = 5
	TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED = 6

	AGENT_LOGIC[CHAR_OCCUPATION.TAX_COLLECTOR] = function (i)
		

		if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES then
			res = TAX_COLLECTOR_COLLECT_TAXES(i)
			
			if res == TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED then
				char_change_state(i, CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES)
			end
			if res == TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS then
				char_change_state(i, CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES)
			end
			if res == TAX_COLLECTOR_RESPONCES.FOUND_TARGET then
				-- ok
			end
			if res == TAX_COLLECTOR_RESPONCES.GOT_TAX then
				-- ok
			end
			if res == TAX_COLLECTOR_RESPONCES.ON_MY_WAY then
				-- ok
			end
		end
		
		if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES then
			res = TAX_COLLECTOR_RETURN_TAXES(i)
			if res == TAX_COLLECTOR_RESPONCES.IN_CASTLE then
				char_change_state(i, CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE)
			end
		end
		
		if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE then
			res = TAX_COLLECTOR_WAIT_IN_CASTLE(i)
			if res == TAX_COLLECTOR_RESPONCES.FOUND_TARGET then
				char_change_state(i, CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES)
			end
		end
		
	end

	function TAX_COLLECTOR_COLLECT_TAXES(i)
		if chars_wealth[i] > MAX_GOLD_TO_CARRY then
			return TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED
		end
		
		if chars_state_target[i] == nil then
			-- if no target, then find the most optimal (wealth to tax / distance) building and set it as a target
			local optimal = 0
			local final_target = nil
			
			for j, w in ipairs(buildings_wealth_before_taxes) do
				if (w > MIN_GOLD_TO_TAX) and (w / char_build_dist(i, j) > optimal) then
					optimal = w / char_build_dist(i, j)
					final_target = j
				end
			end
			
			if final_target == nil then
				return TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS
			end
			
			chars_state_target[i] = final_target
			chars_target[i].x = buildings_x(final_target)
			chars_target[i].y = buildings_y(final_target)
			return TAX_COLLECTOR_RESPONCES.FOUND_TARGET
		elseif chars_state_target[i] ~= nil then
			if char_build_dist(i, chars_state_target[i]) < 0.5 then
				char_tax_building(i, chars_state_target[i])
				chars_state_target[i] = nil
				return TAX_COLLECTOR_RESPONCES.GOT_TAX
			else 
				char_move_to_target(i)
				return TAX_COLLECTOR_RESPONCES.ON_MY_WAY
			end
		end
	end

	function TAX_COLLECTOR_RETURN_TAXES(i)
		if chars_state_target[i] == nil then
			local closest_tax_storage = 1
			chars_state_target[i] = 1
			chars_target[i].x = buildings_x(closest_tax_storage)
			chars_target[i].y = buildings_y(closest_tax_storage)
		elseif chars_state_target[i] ~= nil then
			if dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
				char_return_tax(i)
				chars_state_target[i] = nil
				return TAX_COLLECTOR_RESPONCES.IN_CASTLE
			else 
				char_move_to_target(i)
				return TAX_COLLECTOR_RESPONCES.ON_MY_WAY
			end
		end
	end

	function TAX_COLLECTOR_WAIT_IN_CASTLE(i)
		local optimal, final_target = FIND_OPTIMAL_BUILDING_TO_TAX(i)
		
		if final_target == nil then
			return TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS
		end
		
		chars_state_target[i] = final_target
		chars_target[i].x = buildings_x(final_target)
		chars_target[i].y = buildings_y(final_target)
		
		return TAX_COLLECTOR_RESPONCES.FOUND_TARGET
	end


end