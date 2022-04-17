---@alias Condition fun(character:Character, event:Event):ConditionResponce

---@type Condition
function TrivialCondition(character, event)
    return true
end
---@type Condition
function TargetReachedCondition(character, event)
    if event == nil then
        return false
    end
    if event.type == "target_reached" then
        return true
    end
    return false
end
---@type Condition
function TargetFoundCondition(character, event)
    if event == nil then
        return false
    end
    if event.type == "target_found" then
        return true
    end
    return false
end
---@type Condition
function CellFoundCondition(character, event)
    -- print("??")
    -- print(event)
    -- print(event.type)
    if event == nil then
        return false
    end
    if event.type == "cell_found" then
        return true
    end
    return false
end
---@type Condition
function ActionFinishedCondition(character, event)
    if event == nil then
        return false
    end
	return event.type == "action_finished"
end
---@type Condition
function ActionFailedCondition(character, event)
    if event == nil then
        return false
    end
	return event.type == "action_failed"
end

---comment
---@type Condition
function TiredCondition(character, event)
    if character:get_tiredness() > character:get_hunger() + 10 then
        return true
    end
end

---comment
---@param character Character
---@param event Event
---@return boolean
function HasHomeCondition(character, event)
    return not (character.home == nil)
end