
local InstructionManager = {}
InstructionManager.__index = InstructionManager

---@class InstructionManager
---@field current_instruction AgentInstruction
---@field current_node InstructionNode
---@field character Character

---comment
---@param character Character
---@return InstructionManager
function InstructionManager:new(character)
    _ = {current_instruction= nil, character= character}
    setmetatable(_, InstructionManager)
    return _
end

function InstructionManager:update(character)
    if self.current_instruction == nil then
        self:select_new_instruction()
        self.current_node:enter(character)
    end
    local event = character:execute_order()
    local responce = self.current_instruction:handle_event(self.current_node, character, event)
    if responce == nil then
        self:select_new_instruction()
    elseif responce == "continue" then
        return
    else
        self.current_node = responce
        self.current_node:enter(character)
    end
end

function InstructionManager:select_new_instruction()
    self.current_instruction = GatherEat
    self.current_node = GatherEat.starting_node
    
end

return InstructionManager