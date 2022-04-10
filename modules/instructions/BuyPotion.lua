local FindShopNode = InstructionNode:new(FindShopBuyPotionAction)
local MoveNode = InstructionNode:new(MoveAction)
local BuyNode = InstructionNode:new(BuyPotionAction)
local EndNode = InstructionNode:new(Empty, true)

FindShopNode
    :add_child(MoveNode, TargetFoundCondition)
    :add_child(EndNode, ActionFailedCondition)
MoveNode
    :add_child(BuyNode, ActionFinishedCondition)
BuyNode
    :add_child(EndNode, ActionFinishedCondition)
    :add_child(EndNode, ActionFailedCondition)

return AgentInstruction:new(FindShopNode, "Buy potion")