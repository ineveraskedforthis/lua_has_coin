local FindFoodNode = InstructionNode:new(FindFoodAction)
local GoToFoodNode = InstructionNode:new(MoveAction)
local GatherFoodNode = InstructionNode:new(CollectFoodAndKeepAction)
local FindShopNode = InstructionNode:new(FindShopAction)
local GoToShopNode = InstructionNode:new(MoveAction)
local SellNode = InstructionNode:new(SellFoodAction)
local EndNode = InstructionNode:new(Empty, true)


FindFoodNode:add_child(GoToFoodNode, TargetFoundCondition)
FindFoodNode:add_child(FindFoodNode, ActionFinishedCondition)

GoToFoodNode:add_child(GatherFoodNode, ActionFinishedCondition)

GatherFoodNode:add_child(FindShopNode, ActionFinishedCondition)

FindShopNode:add_child(GoToShopNode, TargetFoundCondition)

GoToShopNode:add_child(SellNode, ActionFinishedCondition)

SellNode:add_child(EndNode, ActionFinishedCondition)
SellNode:add_child(EndNode, ActionFailedCondition)


local SellFoodInstruction = AgentInstruction:new(FindFoodNode, "Sell food")
return SellFoodInstruction