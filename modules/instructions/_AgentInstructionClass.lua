---@class AgentInstruction
---@field stage "idle"|"move"
---@field starting_node InstructionNode
local AgentInstruction = {}
AgentInstruction.__index = AgentInstruction


---comment
---@return AgentInstruction
function AgentInstruction:new(starting_node)
    local _ = { starting_node= starting_node }
    setmetatable(_, self)
    return _
end

function AgentInstruction:run(character)
    
    return "finished"
end


---Returns "final" if current instruction is over
---Return "ok" if current instruction is still in process
---Returns nil if something broke
---@param node InstructionNode
---@param character Character
---@param event Event
---@return "ok"|"final"|nil
function AgentInstruction:handle_event(node, character, event)
    local tmp_node = node:select_child(character, event)
    if tmp_node == nil then
        return "continue"
    end
    if tmp_node.end_node then
        return nil
    end
    return tmp_node
end




return AgentInstruction

