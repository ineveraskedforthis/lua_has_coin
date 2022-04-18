local GoCastleNode = InstructionNode:new(MoveToCastleAction)
local TakeQuestNode = InstructionNode:new(ClaimRewardAction)
local LookForRatNode = InstructionNode:new(SearchForRatAction)
local AttackRatNode = InstructionNode:new(AttackAction)
local SleepNode = InstructionNode:new(SleepGroundAction)
local BackToCastleNode = InstructionNode:new(MoveToCastleAction)
local RecieveRewardNode = InstructionNode:new(RecieveRewardAction)
local EndNode = InstructionNode:new(Empty, true)


local FindFood = InstructionNode:new(FindFoodAction)
local GoToFood = InstructionNode:new(MoveAction)
local CollectFood = InstructionNode:new(CollectFoodAndEatAction)


GoCastleNode:add_child(TakeQuestNode, ActionFinishedCondition)

--- if quest was taken, continue, otherwise break 
TakeQuestNode:add_child(LookForRatNode, ActionFinishedCondition)
TakeQuestNode:add_child(EndNode, ActionFailedCondition)

--- look for a rat until rat is found or contract expires 
LookForRatNode:add_child(LookForRatNode, ActionFinishedCondition)
LookForRatNode:add_child(EndNode, ActionFailedCondition)
LookForRatNode:add_child(AttackRatNode, TargetFoundCondition)
--- interrupt on resting/eating
LookForRatNode:add_child(FindFood, HungryCondition)
LookForRatNode:add_child(SleepNode, TiredCondition)



--- return to searching for rat when needs are satisfied
SleepNode:add_child(LookForRatNode, ActionFinishedCondition)

FindFood:add_child(GoToFood, TargetFoundCondition)
FindFood:add_child(FindFood, ActionFinishedCondition)

GoToFood:add_child(FindFood, ActionFailedCondition)
GoToFood:add_child(CollectFood, ActionFinishedCondition)

CollectFood:add_child(FindFood, ActionFailedCondition)
CollectFood:add_child(LookForRatNode, ActionFinishedCondition)



AttackRatNode:add_child(BackToCastleNode, ActionFinishedCondition)
AttackRatNode:add_child(LookForRatNode, TargetDiedCondition)
BackToCastleNode:add_child(RecieveRewardNode, ActionFinishedCondition)
RecieveRewardNode:add_child(EndNode, ActionFinishedCondition)

return AgentInstruction:new(GoCastleNode, "Taking hunt quest")