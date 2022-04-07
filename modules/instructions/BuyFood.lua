local FindShopNode = InstructionNode:new(FindShopAction)
local MoveNode = InstructionNode:new(MoveAction)
local BuyFoodNode = InstructionNode:new(BuyFood)
local EndNode = InstructionNode:new(Empty, true)

FindShopNode
    :add_child(MoveNode, TargetFoundCondition)
    :add_child(EndNode, ActionFailedCondition)
MoveNode
    :add_child(BuyFoodNode, ActionFinishedCondition)
BuyFoodNode
    :add_child(EndNode, ActionFinishedCondition)
    :add_child(EndNode, ActionFailedCondition)

local BuyEatInstruction = AgentInstruction:new(FindShopNode, "Buy some food")

return BuyEatInstruction
