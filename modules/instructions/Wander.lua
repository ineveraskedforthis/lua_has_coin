local function WanderAction(character)
    character:set_order_Wander()
end

local EndNode = InstructionNode:new(Empty, true)
local WanderNode = InstructionNode:new(WanderAction)
WanderNode:add_child(EndNode, ActionFinishedCondition)

local WanderInstruction = AgentInstruction:new(WanderNode)

return WanderInstruction