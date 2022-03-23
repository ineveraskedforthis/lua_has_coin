function CollectWood(character)
    character:set_order("gather_wood")
end

function BringWoodBack(character)
    character:set_order("bring_wood")
end

function FindPlaceForShop(character)
    character:set_order_WanderForVacantSpace()
end

function SetUpShopSpot(character)
    character:set_order("set_up_shop")
end


---@type Action
function ReturnToCastle(character)
    character:set_order("return_to_castle")
end

local ReturnToCastleNode = InstructionNode:new(ReturnToCastle)
local FindShopPlaceNode = InstructionNode:new(FindPlaceForShop)
local SetUpShopSpotNode = InstructionNode:new(SetUpShopSpot)
local CollectWoodNode = InstructionNode:new(CollectWood)
local BringWoodBack = InstructionNode:new(BringWoodBack)

ReturnToCastleNode:add_child(FindShopPlaceNode, ActionFinishedCondition)
FindShopPlaceNode:add_child(SetUpShopSpotNode, TargetFoundCondition)