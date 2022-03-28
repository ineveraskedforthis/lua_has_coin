InstructionNode = require "modules.instructions._InstructionNodeClass"



---Orders character to sleep
---@param character Character
function SleepAction(character)
    character:set_order("rest_on_ground")
end
---Commands character to go home
---@param character Character
function GoHomeAction(character)
    character:set_order("return_home")
end
---Commands character to go home
---@param character Character
function SleepHomeAction(character)
    character:set_order("rest")
end

local StartNode = InstructionNode:new(Empty)
local EndNode = InstructionNode:new(Empty, true)

local SleepAtGroundNode = InstructionNode:new(SleepAction)

local GoHomeNode = InstructionNode:new(GoHomeAction)
local SleepAtHomeNode = InstructionNode:new(SleepHomeAction)

StartNode:add_child(GoHomeNode, HasHomeCondition)
    GoHomeNode:add_child(SleepAtHomeNode, ActionFinishedCondition)
    SleepAtHomeNode:add_child(EndNode, ActionFinishedCondition)

StartNode:add_child(SleepAtGroundNode, TrivialCondition)
    SleepAtGroundNode:add_child(EndNode, ActionFinishedCondition)

local SleepInstruction = AgentInstruction:new(StartNode)

return SleepInstruction