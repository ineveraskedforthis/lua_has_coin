local MoveNode = InstructionNode:new(MoveToCastleAction)
local GetPaidNode = InstructionNode:new(GetPaymentAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(GetPaidNode, ActionFinishedCondition)
GetPaidNode:add_child(EndNode, ActionFailedCondition)
GetPaidNode:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction:new(MoveNode, "Get paid")

return instruction