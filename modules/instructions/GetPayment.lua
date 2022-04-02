---comment
---@param character Character
local function GoToCastleAction(character)
    character:set_target(castle)
    character:set_order('move')
end

local function GetJobAction(character)
    character:set_order('get_paid')
end 

local MoveNode = InstructionNode:new(GoToCastleAction)
local GetPaidNode = InstructionNode:new(GetJobAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(GetPaidNode, ActionFinishedCondition)
GetPaidNode:add_child(EndNode, ActionFailedCondition)
GetPaidNode:add_child(EndNode, ActionFinishedCondition)

local instruction = AgentInstruction:new(MoveNode, "Get paid")

return instruction