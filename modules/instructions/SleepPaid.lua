--- Characters always can sleep at castle if they have enough money
--- I should add ability to build inns later
local GoCastleNode = InstructionNode:new(MoveToCastleAction)
local SleepNode = InstructionNode:new(SleepCastleAction)
local EndNode = InstructionNode:new(Empty, true)

GoCastleNode:add_child(SleepNode, ActionFinishedCondition)
SleepNode:add_child(EndNode, ActionFinishedCondition)

local SleepPaidInstruction = AgentInstruction:new(GoCastleNode, "Sleep at the castle")

return SleepPaidInstruction