---@class NodeResponce
---@class ConditionResponce



---@alias Action fun(character:Character):NodeResponce

---@class Edge
---@field node InstructionNode
---@field condition Condition

---@class InstructionNode
---@field action fun(character:Character):NodeResponce
---@field children Edge[]
---@field end_node boolean
local InstructionNode = {}
InstructionNode.__index = InstructionNode

---takes action and end_node boolean flag as input
---@param action Action
---@param end_node boolean
---@return InstructionNode
function InstructionNode:new(action, end_node)
    local _ = { action = action, end_node = false , children= {}}
    if end_node ~= nil then
        _.end_node = end_node
    end
    setmetatable(_, self)
    return _
end

function InstructionNode:enter(character)
    local responce = self.action(character)
    return responce
end

---processes event and chooses a next node if needed
---@param event Event
---@return InstructionNode
function InstructionNode:process_event(event)

end

---adds new child to node
---children are checked in order of adding
---@param node InstructionNode
---@param condition fun(character:Character):boolean
function InstructionNode:add_child(node, condition)
    table.insert(self.children, {node=node, condition=condition})
end

---returns next node to use.  
---returns "falied" if no legit child found
---@param character Character
---@param event Event
---@return InstructionNode|nil
function InstructionNode:select_child(character, event)
    for _, child in pairs(self.children) do
        if child.condition(character, event) then
            return child.node
        end
    end
    return nil
end


return InstructionNode