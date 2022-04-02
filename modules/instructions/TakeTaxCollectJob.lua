---comment
---@param character Character
local function GoToCastleAction(character)
    character:set_target(castle)
    character:set_order('move')
end

local function GetJobAction(character)
    character:set_order('apply')
end 

local MoveNode = InstructionNode:new(GoToCastleAction)
local GetJob = InstructionNode:new(GetJobAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(GetJob, ActionFinishedCondition)
GetJob:add_child(EndNode, ActionFailedCondition)
GetJob:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction:new(MoveNode, "Take job")

return instruction