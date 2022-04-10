local GoToSafeNode = InstructionNode:new(MoveToCastleAction)
local MakeNode = InstructionNode:new(MakePotionAction) 
local EndNode = InstructionNode:new(Empty, true)
GoToSafeNode:add_child(MakeNode, ActionFinishedCondition)
MakeNode:add_child(EndNode, ActionFinishedCondition)

return AgentInstruction:new(GoToSafeNode, "Making potion")