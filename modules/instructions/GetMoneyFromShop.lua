--- takes 50 gold from shop
local MoveNode = InstructionNode:new(MoveToHomeAction)
local TakeNode = InstructionNode:new(TakeGoldAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(TakeNode, ActionFinishedCondition)
TakeNode:add_child(EndNode, ActionFinishedCondition)
TakeNode:add_child(EndNode, ActionFailedCondition)

local instruction = AgentInstruction:new(MoveNode, "Get money from shop")

return instruction