---@class EventTargeted
---@field type "spotted_enemy"
---@field target Target 

---@class EventSimple
---@field type "hunt_started"|"target_killed"

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
function Event_TargetReached()
	return {type = "target_reached"}
end

function Event_ActionFailed()
	return {type= "action_failed"}
end
function Event_ActionFinished()
	return {type= "action_finished"}
end

---@alias Event EventTargeted|EventSimple
