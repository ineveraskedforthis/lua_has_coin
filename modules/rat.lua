function init_rat()
	-- RAT
	---- rats are common vermin that hurts your early stage of the kingdom 


	-- RAT SETTINGS
	RAT_DISTANCE_FROM_LAIR = 410

	-- RAT STATES
	CHAR_STATE.RAT_PROTECT_LAIR = new_state_id()

	-- HUNTER RESPONCES
	RAT_RESPONCES = {}
	RAT_RESPONCES.ON_MY_WAY = 1
	RAT_RESPONCES.FOUND_TARGET = 2
	RAT_RESPONCES.TARGET_REACHED = 3
	RAT_RESPONCES.NO_ENEMIES = 4

	AGENT_LOGIC[CHAR_OCCUPATION.RAT] = function (i)
		RAT_PROTECT_LAIR(i)
	end

	function RAT_PROTECT_LAIR(i)
		local closest_hero = nil
		local curr_dist = 20
		for j, f in pairs(ALIVE_HEROES) do
			if f then
				local tmp = char_dist(j, i)
				if ((closest_hero == nil) and (tmp < curr_dist)) or (tmp < curr_dist) then
					closest_hero = j
					curr_dist = tmp
				end
			end
		end
		local from_home_dist = char_build_dist(i, chars_home[i])
		if (closest_hero ~= nil) and (from_home_dist < RAT_DISTANCE_FROM_LAIR) then
			chars_target[i] = {}
			chars_target[i].x = chars_x[closest_hero]
			chars_target[i].y = chars_y[closest_hero]
			if curr_dist > 1 then 
				char_move_to_target(i)
			else
				char_attack_char(i, closest_hero)
			end
		elseif chars_target[i].x == nil then
			local dice = math.random() - 0.5
			chars_target[i].x = dice * dice * dice * 800 + buildings_x(chars_home[i])
			local dice = math.random() - 0.5
			chars_target[i].y = dice * dice * dice * 800 + buildings_y(chars_home[i])
		elseif chars_target[i].x ~= nil then
			res = char_move_to_target(i)
			if res == MOVEMENT_RESPONCES.TARGET_REACHED then
				chars_target[i].x = nil
				chars_target[i].y = nil
			end
		end
	end
end