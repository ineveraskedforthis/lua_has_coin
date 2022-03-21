InstructionNode = require "modules.instructions._InstructionNodeClass"

---Orders character to sleep
---@param character Character
function SleepAction(character)
    character:set_order("rest_on_ground")
end


local EndNode = InstructionNode:new(Empty, true)

local SleepNode = InstructionNode:new(SleepAction)

SleepNode:add_child(EndNode, ActionFinishedCondition)


local SleepInstruction = AgentInstruction:new(SleepNode)

return SleepInstruction