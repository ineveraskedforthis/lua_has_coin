local GatherEat = require "GatherEat"
local InstructionManager = {}
InstructionManager.__index = InstructionManager

---@class InstructionManager
---@field current_instruction AgentInstruction
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
    local event = character:execute_order()
    local responce = self.current_instruction:handle_event(event)
    if responce == "final" then
        self:select_new_instruction()
    end
end

function InstructionManager:select_new_instruction()
    self.current_instruction = GatherEat:reset()
end

