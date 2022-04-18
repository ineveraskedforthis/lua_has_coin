---@class EventTargeted
---@field type string
---@field target Target 

---@class EventCell
---@field type string
---@field target Cell 

---@class EventSimple
---@field type string

---Returns new event with passed target
---@param target Target
---@return EventTargeted
function Event_EnemySpotted(target)
	return {type="spotted_enemy", target = target}
end

---comment
---@return EventSimple
function Event_EnemyKilled()
	return {type="target_killed"}
end

---@return EventTargeted
function Event_TargetFound(target)
	return {type="target_found", target=target}
end

---@return EventCell
function Event_CellFound(target)
	return {type="cell_found", target=target}
end
function Event_TargetReached()
	return {type = "target_reached"}
end
function Event_TargetDied()
	return {type = "target_died"}
end

function Event_ActionFailed()
	return {type= "action_failed"}
end
function Event_ActionFinished()
	return {type= "action_finished"}
end
function Event_ActionInProgress()
	return {type= "action_in_progress"}
end

function Event_print(event)
	if event == "continue" then
		print("Event continue")
	end
	if event == nil then
		print("Event nil")
		return
	end
	print("Event " .. event.type)
end

function Event_NewAgent(template, position, home)
	return {type="new_agent", template = template, position = position, home=home}
end
function Event_Death()
	return {type="death"}
end


---@alias Event EventTargeted|EventSimple
