local FindNode = InstructionNode:new(FindTaxTargetAction)
local MoveNode = InstructionNode:new(MoveAction)
local TaxNode = InstructionNode:new(TaxTargetAction)
local ReturnToCastleNode = InstructionNode:new(ReturnToCastleAction)
local ReturnTaxNode = InstructionNode:new(ReturnTaxesAction)
local EndNode = InstructionNode:new(Empty, true)

FindNode:add_child(MoveNode, TargetFoundCondition)
FindNode:add_child(EndNode, ActionFailedCondition)
MoveNode:add_child(TaxNode, ActionFinishedCondition)
TaxNode:add_child(ReturnToCastleNode, ActionFinishedCondition)
TaxNode:add_child(EndNode, ActionFailedCondition)
ReturnToCastleNode:add_child(ReturnTaxNode, ActionFinishedCondition)
ReturnTaxNode:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction:new(FindNode, "Collect tax")

return instruction