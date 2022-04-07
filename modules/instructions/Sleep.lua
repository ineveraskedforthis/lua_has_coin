local StartNode = InstructionNode:new(Empty)
local EndNode = InstructionNode:new(Empty, true)

local SleepAtGroundNode = InstructionNode:new(SleepGroundAction)

local GoHomeNode = InstructionNode:new(MoveToHomeAction)
local SleepAtHomeNode = InstructionNode:new(SleepHomeAction)

StartNode:add_child(GoHomeNode, HasHomeCondition)
    GoHomeNode:add_child(SleepAtHomeNode, ActionFinishedCondition)
    SleepAtHomeNode:add_child(EndNode, ActionFinishedCondition)

StartNode:add_child(SleepAtGroundNode, TrivialCondition)
    SleepAtGroundNode:add_child(EndNode, ActionFinishedCondition)

local SleepInstruction = AgentInstruction:new(StartNode, "Sleep for free")

return SleepInstruction