local function FindTargetAction(character)
    character:set_order("find_tax_target")
end

local function MoveToTaxTargetAction(character)
    character:set_order("move")
end

local function TaxTargetAction(character)
    character:set_order("tax_target")
end

local function ReturnToCastleAction(character)
    character:set_target(castle)
    character:set_order("move")
end

local function ReturnTaxesAction(character)
    character:set_order("return_tax")
end

local FindNode = InstructionNode:new(FindTargetAction)
local MoveNode = InstructionNode:new(MoveToTaxTargetAction)
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