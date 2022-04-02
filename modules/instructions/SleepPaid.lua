--- Characters always can sleep at castle if they have enough money
--- I should add ability to build inns later

---comment
---@param character Character
local function GoToCastleAction(character)
    character:set_order('return_to_castle')
end

local function SleepAction(character)
    if character.wealth < castle.SLEEP_PRICE then
        character:set_order('rest_on_ground')
        return
    end
    character.wealth = character.wealth - castle.SLEEP_PRICE
    castle:add_wealth(castle.SLEEP_PRICE)
    character:set_order('rest_at_castle')
end

local GoCastleNode = InstructionNode:new(GoToCastleAction)
local SleepNode = InstructionNode:new(SleepAction)
local EndNode = InstructionNode:new(Empty, true)

GoCastleNode:add_child(SleepNode, ActionFinishedCondition)
SleepNode:add_child(EndNode, ActionFinishedCondition)

local SleepPaidInstruction = AgentInstruction:new(GoCastleNode, "Sleep at the castle")

return SleepPaidInstruction