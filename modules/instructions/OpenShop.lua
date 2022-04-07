local EndNode = InstructionNode:new(Empty, true)
local ReturnToCastleNode = InstructionNode:new(MoveToCastleAction)
local FindShopPlaceNode = InstructionNode:new(FindPlaceForShop)
local SetUpShopSpotNode = InstructionNode:new(SetUpShopSpot)

ReturnToCastleNode:add_child(FindShopPlaceNode, ActionFinishedCondition)
FindShopPlaceNode:add_child(SetUpShopSpotNode, CellFoundCondition)
FindShopPlaceNode:add_child(FindShopPlaceNode, ActionFinishedCondition)
SetUpShopSpotNode:add_child(EndNode, TrivialCondition)

local SetUpShopSpotInstruction = AgentInstruction:new(ReturnToCastleNode, "Open new shop")
return SetUpShopSpotInstruction