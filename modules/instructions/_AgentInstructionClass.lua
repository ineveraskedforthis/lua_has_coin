---@class AgentInstruction
---@field stage "idle"|"move"
---@field current_node InstructionNode
---@field starting_node InstructionNode
local AgentInstruction = {}
AgentInstruction.__index = AgentInstruction


---comment
---@return AgentInstruction
function AgentInstruction:new(starting_node)
    local _ = { current_node = starting_node, starting_node= starting_node }
    setmetatable(_, self)
    return _
end

function AgentInstruction:run(character)
    
    return "finished"
end


---Returns "final" if current instruction is over
---Return "ok" if current instruction is still in process
---Returns nil if something broke
---@param character Character
---@param event Event
---@return "ok"|"final"|nil
function AgentInstruction:handle_event(character, event)
    local node = self.current_node.select_child(character, event)
    if node == nil then
        return "ok"
    end
    if node.end_node then
        return "final"
    end
    self.current_node = node
    return "ok"
end

function AgentInstruction:reset()
    self.current_node = self.starting_node
end



return AgentInstruction




--example:
