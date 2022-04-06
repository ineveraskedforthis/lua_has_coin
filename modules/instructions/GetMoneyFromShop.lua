--- takes 50 gold from shop


function GoHomeAction(character)
    character.set_target(character.home)
    character.set_order("move")
end

function TakeGoldAction(character)
    character.set_order("take_gold")
end

local MoveNode = InstructionNode:new(GoHomeAction)
local TakeNode = InstructionNode:new(TakeGoldAction)
local EndNode = InstructionNode:new(Empty, true)

MoveNode:add_child(TakeNode, ActionFinishedCondition)
TakeNode:add_child(EndNode, ActionFinishedCondition)
TakeNode:add_child(EndNode, ActionFailedCondition)

local instruction = AgentInstruction:new(MoveNode)

return instruction