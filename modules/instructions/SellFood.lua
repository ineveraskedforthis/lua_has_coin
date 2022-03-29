---comment
---@param character Character
local function FindFoodAction(character)
    character.set_order_WanderForFood()
end
local function CollectFoodAction(character)
    character.set_order("collect_food")
end 
local function FindShopAction(character)
    character.set_order("find_shop")
end 
local function GoToShopAction(character)
    character.set_order("move")
end
local function SellAction(character)
    character.set_order("sell")
end


local FindFoodNode = InstructionNode:new(FindFoodAction)
local GatherFoodNode = InstructionNode:new(CollectFoodAction)
local FindShopNode = InstructionNode:new(FindShopAction)
local GoToShopNode = InstructionNode:new(GoToShopAction)
local SellNode = InstructionNode:new(SellAction)
local EndNode = InstructionNode:new(Empty, true)

FindFoodNode:add_child(GatherFoodNode, TargetFoundCondition)
FindFoodNode:add_child(FindFoodNode, ActionFinishedCondition)

GatherFoodNode:add_child(FindShopNode, ActionFinishedCondition)

FindShopNode:add_child(GoToShopAction, TargetFoundCondition)

GoToShopNode:add_child(SellNode, ActionFinishedCondition)

SellNode:add_child(EndNode, ActionFinishedCondition)
SellNode:add_child(EndNode, ActionFailedCondition)

local SellFoodInstruction = AgentInstruction:new(FindFoodNode)

return SellFoodInstruction