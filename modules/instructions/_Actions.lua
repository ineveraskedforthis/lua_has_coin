function Empty(character)

end


function MoveAction(character)
    character:set_order(OrderMove)
end
function WanderAction(character)
    character:set_order(OrderWander)
end
function WanderFoodAction(character)
    character:set_order(OrderWanderFood)
end
function WanderSpaceAction(character)
    character:set_order(OrderWanderSpace)
end
function MoveToCastleAction(character)
    character:set_target(castle)
    character:set_order(OrderMove)
end
function MoveToHomeAction(character)
    character:set_target(character.home)
    character:set_order(OrderMove)
end



function BuyFoodAction(character)
    character:set_order(OrderBuyFood)
end
function SellFoodAction(character)
    character:set_order(OrderSellFood)
end
function CollectFoodAndKeepAction(character)
    character:set_order(OrderGatherKeep)
end 
function CollectFoodAndEatAction(character)
    character:set_order(OrderGatherEat)
end
function SellPotionAction(character)
    character:set_order(OrderSellPotion)
end
function BuyPotionAction(character)
    character:set_order(OrderBuyPotion)
end



function FindTaxTargetAction(character)
    character:set_order(OrderFindTaxTarget)
end
---@param character Character
function FindFoodAction(character)
    character:set_order(OrderWanderFood)
end
function FindShopSellFoodAction(character)
    character:set_order(OrderFindShopSellFood)
end
function FindShopBuyFoodAction(character)
    character:set_order(OrderFindShopBuyFood)
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
    character:set_order(OrderApplyForJob)
end 
function GetPaymentAction(character)
    character:set_order(OrderGetPaid)
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
end




function TakeGoldAction(character)
    character:set_order(OrderTakeGoldFromHome)
end


---Orders character to sleep
---@param character Character
function SleepGroundAction(character)
    character:set_order(OrderRestGround)
end
---Commands character to rest at home
---@param character Character
function SleepHomeAction(character)
    character:set_order(OrderRestHome)
end
function SleepCastleAction(character)
    character.wealth = character.wealth - castle.SLEEP_PRICE
    castle:income(castle.SLEEP_PRICE)
    character:set_order(OrderRestCastle)    
end


function ApplyToJobAction(character)
    character:set_order(OrderApplyForJob)
end 
