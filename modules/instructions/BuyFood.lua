local function FindShopAction(character)
    character:set_order("find_shop")
end

local function MoveToShopAction(character)
    character:set_order("move")
end

local function BuyFood(character)
    character:set_order("buy_eat")
end

local FindShopNode = InstructionNode:new(FindShopAction)
local MoveNode = InstructionNode:new(MoveToShopAction)
local BuyFoodNode = InstructionNode:new(BuyFood)
local EndNode = InstructionNode:new(Empty, true)

FindShopNode
    :add_child(MoveNode, TargetFoundCondition)
    :add_child(EndNode, ActionFailedCondition)
MoveNode
    :add_child(BuyFoodNode, ActionFinishedCondition)
BuyFoodNode
    :add_child(EndNode, ActionFinishedCondition)
    :add_child(EndNode, ActionFailedCondition)

local BuyEatInstruction = AgentInstruction:new(FindShopNode)

return BuyEatInstruction
