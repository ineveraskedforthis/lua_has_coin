function CollectWood(character)
    character:set_order("gather_wood")
end

function BringWoodBack(character)
    character:set_order("bring_wood")
end

function FindPlaceForShop(character)
    -- print("????")
    character:set_order_WanderForVacantSpace()
end

---@param character Character
function SetUpShopSpot(character)
    -- print("!!!!")
    local shop = Building:new(character.target, "shop", 0, character)
    character:set_home(shop)
    character.has_shop = true
    add_building(shop)
    character:set_order("set_up_shop")
end


---@type Action
function ReturnToCastle(character)
    character:set_order("return_to_castle")
end


local EndNode = InstructionNode:new(Empty)
local ReturnToCastleNode = InstructionNode:new(ReturnToCastle)
local FindShopPlaceNode = InstructionNode:new(FindPlaceForShop)
local SetUpShopSpotNode = InstructionNode:new(SetUpShopSpot)

ReturnToCastleNode:add_child(FindShopPlaceNode, ActionFinishedCondition)
FindShopPlaceNode:add_child(SetUpShopSpotNode, CellFoundCondition)
FindShopPlaceNode:add_child(FindShopPlaceNode, ActionFinishedCondition)
SetUpShopSpotNode:add_child(EndNode, TrivialCondition)

local SetUpShopSpotInstruction = AgentInstruction:new(ReturnToCastleNode)
return SetUpShopSpotInstruction