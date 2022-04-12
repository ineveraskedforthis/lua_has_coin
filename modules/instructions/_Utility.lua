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
--- A8:
---		applying for a royal job has Payment * 10 utility

---@class UtilitySource
---@field instruction AgentInstruction
---@field utility function
---@field long_term_utility function
---@field required_wealth function
---@field wealth_income function
UtilitySource = {}
UtilitySource.__index = UtilitySource
function UtilitySource:new(instruction, utility, required_wealth, wealth_income, long_term_utility)
	_ = {}
	_.instruction = instruction
	_.utility = utility
	_.long_term_utility = long_term_utility
	_.required_wealth = required_wealth
	_.wealth_income = wealth_income
	setmetatable(_, UtilitySource)
	return _
end

---Gets character and decides for him the best current instruction
---@param character Character
---@return AgentInstruction
function MostUsefulAction(character, sources)
	local raw_utility = {}
	local price = {}
	local money_utility_total = 0
	local money_required_total = 0
	local money_earning_utility = 0
	for _, source in pairs(sources) do
		local temp_utility = source.utility(character) 
		local temp_wealth = source.required_wealth(character)
		if temp_wealth == nil then
			--- it means that this thing is unavailable
		elseif temp_wealth > character:get_wealth() then
			if temp_wealth ~= 0 then
				money_earning_utility = math.max(
					money_earning_utility,
					(temp_utility))
			end
			price[_]  = temp_wealth
		else
			raw_utility[_] = temp_utility
			price[_]  = temp_wealth
		end

		if (temp_wealth ~= nil) then
			local long_term_temp_wealth = temp_wealth * character.traits.long_term_planning
			local long_term_temp_utility = (temp_utility + source.long_term_utility(character) * character.traits.long_term_planning)
			if (long_term_temp_wealth > character:get_wealth()) then
				if temp_wealth ~= 0 then
					money_earning_utility = math.max(
						money_earning_utility,
						math.floor(long_term_temp_utility * character:get_wealth() / long_term_temp_wealth))
				end
			end
		end 
	end

	local true_utility = {}
	for ind, _ in pairs(raw_utility) do
		local source = sources[ind]
		local income = source.wealth_income(character)
		if income > 0 then
			true_utility[ind] = _ + (income - price[ind]) + money_earning_utility 
		else
			true_utility[ind] = _ + (income - price[ind])
		end
	end

	local optimal = nil
	for k, v in pairs(true_utility) do
		-- print(v)
		if optimal == nil or true_utility[optimal] < v then
			optimal = k
		end
	end	
	
	-- print(optimal)
	-- print(sources[optimal])
	return sources[optimal].instruction
end