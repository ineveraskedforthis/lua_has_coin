local FindFood = InstructionNode:new(FindFoodAction)
local GoToFood = InstructionNode:new(MoveAction)
local CollectFood = InstructionNode:new(GatherEatAction)
local EndNode = InstructionNode:new(Empty, true)
FindFood:add_child(GoToFood, TargetFoundCondition)
FindFood:add_child(FindFood, ActionFinishedCondition)
FindFood:add_child(EndNode, TiredCondition)

GoToFood:add_child(FindFood, ActionFailedCondition)
GoToFood:add_child(CollectFood, ActionFinishedCondition)

CollectFood:add_child(FindFood, ActionFailedCondition)
CollectFood:add_child(EndNode, ActionFinishedCondition)

local GatherFoodInstruction = AgentInstruction:new(FindFood, "Gather food")

return GatherFoodInstruction