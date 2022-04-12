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

local function utility_eat_free(character)
	return character:get_hunger() * 0.5
end


local function utility_wander(character)
	return 40
end
local function utility_zero(character)
	return 0
end

local function wealth_none(character)
	return 0
end
local function income_none(character)
	return 0
end


local SleepFree = 	UtilitySource:new(SleepInstruction, 			utility_sleep_free, 	wealth_none, 		income_none, 		utility_zero)
local EatFree =		UtilitySource:new(GatherFoodInstruction,		utility_eat_free,		wealth_none,		income_none, 		utility_zero)
local Wander = 		UtilitySource:new(WanderInstruction, 			utility_wander, 		wealth_none, 		income_none, 		utility_zero)

local sources = {SleepFree, EatFree, Wander}


return sources