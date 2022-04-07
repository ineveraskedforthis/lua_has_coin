

local MoveNode = InstructionNode:new(MoveToCastleAction)
local GetJob = InstructionNode:new(GetJobAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(GetJob, ActionFinishedCondition)
GetJob:add_child(EndNode, ActionFailedCondition)
GetJob:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction:new(MoveNode, "Take job")

return instruction