---comment
---@param character Character
local function GoToCastleAction(character)
    character:set_target(castle)
    character:set_order('move')
end

local function GetJobAction(character)
    character:set_order('apply')
end 

local MoveNode = InstructionNode(GoToCastleAction)
local GetJob = InstructionNode(GetJobAction)
local EndNode = InstructionNode(Empty, true)

MoveNode:add_child(GetJob, ActionFinishedCondition)
GetJob:add_child(EndNode, ActionFailedCondition)
GetJob:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction(MoveNode, "Take job")