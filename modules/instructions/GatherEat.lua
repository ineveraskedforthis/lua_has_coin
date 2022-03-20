InstructionNode = require "modules.instructions._InstructionNodeClass"

---Gives character an order to move toward target
---@type Action
function MoveToTarget(character)
    character:set_order("move")
end
---@type Action
function FindFood(character)
    character:set_order_WanderForFood()
end
---@type Action
function CollectFood(character)
    character:set_order("gather_eat")
end
---@type Action
function Empty(character)

end

---@type Condition
function TrivialCondition(character, event)
    return true
end
---@type Condition
function TargetReachedCondition(character, event)
    if event.type == "target_reached" then
        return true
    end
    return false
end
---@type Condition
function TargetFoundCondition(character, event)
    if event.type == "target_found" then
        return true
    end
    return false
end
---@type Condition
function ActionFinishedCondition(character, event)
	return event.type == "action_finished"
end
---@type Condition
function ActionFailedCondition(character, event)
	return event.type == "action_failed"
end



local EndNode = InstructionNode:new(Empty, true)

local FindFood = InstructionNode:new(FindFood)
local GoToFood = InstructionNode:new(MoveToTarget)
local CollectFood = InstructionNode:new(CollectFood)

FindFood.add_child(GoToFood, TargetFoundCondition)
FindFood.add_child(FindFood, ActionFinishedCondition)

GoToFood.add_child(FindFood, ActionFailedCondition)
GoToFood.add_child(CollectFood, ActionFinishedCondition)

CollectFood.add_child(FindFood, ActionFailedCondition)
CollectFood.add_child(EndNode, ActionFinishedCondition)

local GatherFoodInstruction = AgentInstruction:new(FindFood)

return GatherFoodInstruction