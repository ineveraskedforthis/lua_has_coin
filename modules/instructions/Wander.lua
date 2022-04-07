

local EndNode = InstructionNode:new(Empty, true)
local WanderNode = InstructionNode:new(WanderAction)
WanderNode:add_child(EndNode, ActionFinishedCondition)

local WanderInstruction = AgentInstruction:new(WanderNode, "Wandering")

return WanderInstruction