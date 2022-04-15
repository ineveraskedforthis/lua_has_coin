Action = {}


function Empty(character)

end



function WanderAction(character)
    character:set_order(Orders.Wander.Nothing)
end
function WanderFoodAction(character)
    character:set_order(Orders.Wander.Food)
end
function WanderSpaceAction(character)
    character:set_order(Orders.Wander.Space)
end


function MoveAction(character)
    character:set_order(Orders.Move.Target)
end
function MoveToCastleAction(character)
    character:set_target(castle)
    character:set_order(Orders.Move.Target)
end
function MoveToHomeAction(character)
    character:set_target(character.home)
    character:set_order(Orders.Move.Target)
end



function BuyFoodAction(character)
    character:set_order(Orders.Buy.Food)
end
function SellFoodAction(character)
    character:set_order(Orders.Sell.Food)
end
function CollectFoodAndKeepAction(character)
    character:set_order(Orders.Gather.Keep)
end 
function CollectFoodAndEatAction(character)
    character:set_order(Orders.Gather.Eat)
end
function SellPotionAction(character)
    character:set_order(Orders.Sell.Potion)
end
function BuyPotionAction(character)
    character:set_order(Orders.Buy.Potion)
end



function FindTaxTargetAction(character)
    character:set_order(Orders.Find.TaxTarget)
end
---@param character Character
function FindFoodAction(character)
    character:set_order(Orders.Wander.Food)
end
function FindShopSellFoodAction(character)
    character:set_order(Orders.Find.ShopSellFood)
end
function FindShopBuyFoodAction(character)
    character:set_order(Orders.Find.ShopBuyFood)
end
function FindShopSellPotionAction(character)
    character:set_order(Orders.Find.ShopSellPotion)
end
function FindShopBuyPotionAction(character)
    character:set_order(Orders.Find.ShopBuyPotion)
end

function TaxTargetAction(character)
    character:set_order(Orders.Money.TaxTarget)
end
function ReturnTaxesAction(character)
    character:set_order(Orders.Money.TaxToCastle)
end
function TakeGoldAction(character)
    character:set_order(Orders.Money.TaxToCastle)
end
function GetJobAction(character)
    character:set_order(Orders.Apply.TaxCollector)
end 
function GetPaymentAction(character)
    character:set_order(Orders.Money.GetPayment)
end



function MakePotionAction(character)
    character:set_order(Orders.Make.Potion)
end



function FindPlaceForShop(character)
    character:set_order(Orders.Wander.Space)
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
    character:set_order(Orders.Money.GetFromHome)
end


---Orders character to sleep
---@param character Character
function SleepGroundAction(character)
    character:set_order(Orders.Rest.Ground)
end
---Commands character to rest at home
---@param character Character
function SleepHomeAction(character)
    character:set_order(Orders.Rest.Home)
end
function SleepCastleAction(character)
    character.wealth = character.wealth - castle.SLEEP_PRICE
    castle:income(castle.SLEEP_PRICE)
    character:set_order(Orders.Rest.Castle)    
end


function ApplyToJobAction(character)
    character:set_order(Orders.Apply.TaxCollector)
end

function ClaimRewardAction(character)
    character:set_order(Orders.Money.ClaimReward)
end

function SearchForRatAction(character)
    character:set_order(Orders.Wander.Rat)
end

function AttackRatAction(character)
    character:set_order(Orders.Attack.Target)
end

function RecieveRewardAction(character)
    character:set_order(Orders.Money.GetReward)
end