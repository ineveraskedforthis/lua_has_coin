function Empty(character)

end


function MoveAction(character)
    character:set_order(OrderMove)
end
function ReturnToCastleAction(character)
    character:set_target(castle)
    character:set_order(OrderMove)
end
function GoHomeAction(character)
    character:set_target(character.home)
    character:set_order(OrderMove)
end


function BuyFood(character)
    character:set_order(OrderBuyFood)
end


function FindTaxTargetAction(character)
    character:set_order(OrderFindTaxTarget)
end
---@param character Character
function FindFoodAction(character)
    character:set_order(OrderWanderFood)
end
function FindShopAction(character)
    character:set_order(OrderFindShop)
end

function TaxTargetAction(character)
    character:set_order(OrderTaxTarget)
end
function ReturnTaxesAction(character)
    character:set_order(OrderReturnTaxCastle)
end
function TakeGoldAction(character)
    character:set_order(OrderTakeGoldFromHome)
end
function GetJobAction(character)
    character:set_order(OrderGetPaid)
end 

function GatherEatAction(character)
    character:set_order(OrderGatherEat)
end




function FindPlaceForShop(character)
    character:set_order(OrderWanderSpace)
end

---@param character Character
function SetUpShopSpot(character)
    local shop = Building:new(character.target, "shop", 0, character)
    character:set_home(shop)
    character:pay(shop, 200)
    character.has_shop = true
    add_building(shop)
    character:set_order(OrderSetUpShop)
end


---@type Action
function ReturnToCastle(character)
    character:set_order("return_to_castle")
end