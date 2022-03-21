
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

---Executes current order of a character and handles resulting event
---@param character Character
function InstructionManager:update(character)
    if self.current_instruction == nil then
        self:select_new_instruction(character)
    end
    local event = character:execute_order()
    local responce = self.current_instruction:handle_event(self.current_node, character, event)
    if responce == "final" then
        self:select_new_instruction(character)
    elseif responce == "continue" then
        return
    else
        self.current_node = responce
        self.current_node:enter(character)
    end
end

---Selects new instruction for a character
---@param character Character
function InstructionManager:select_new_instruction(character)
    if character.tiredness > 70 then
        self:set_instruction(character, SleepInstruction)
        return
    end
    
    self:set_instruction(character, GatherFoodInstruction)
end

---Sets new current instruction
---@param instruction AgentInstruction
function InstructionManager:set_instruction(character, instruction)
    self.current_instruction = instruction
    self.current_node = instruction.starting_node
    self.current_node:enter(character)
end

return InstructionManager