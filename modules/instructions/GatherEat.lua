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




local EndNode = InstructionNode:new(Empty, true)

local FindFood = InstructionNode:new(FindFood)
local GoToFood = InstructionNode:new(MoveToTarget)
local CollectFood = InstructionNode:new(CollectFood)

FindFood:add_child(GoToFood, TargetFoundCondition)
FindFood:add_child(FindFood, ActionFinishedCondition)
FindFood:add_child(EndNode, TiredCondition)

GoToFood:add_child(FindFood, ActionFailedCondition)
GoToFood:add_child(CollectFood, ActionFinishedCondition)

CollectFood:add_child(FindFood, ActionFailedCondition)
CollectFood:add_child(EndNode, ActionFinishedCondition)

local GatherFoodInstruction = AgentInstruction:new(FindFood)

return GatherFoodInstruction