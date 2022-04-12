local InstructionManager = require "modules.instructions._InstructionManager"

---@class ObjectsManager
---@field agents Agent[]
---@field last_agent number
local ObjectsManager = {}
ObjectsManager.__index = ObjectsManager

function ObjectsManager:new()
    _  = {}
    _.agents = {}
    _.last_agent = 0
    setmetatable(_, ObjectsManager)
    return _
end

---Creates a new agent, adds it to UI and returns it.
---@param ui UI
---@param template table
---@param position Position
---@param home Building|nil
---@return Agent
function ObjectsManager:new_agent(ui, template, position, home)
    local character = Character:new(template, position)
    character:set_home(home)
    local manager = InstructionManager:new(character)
    local agent = {character= character, ai= manager}

    self.agents[self.last_agent + 1] = agent
    self.last_agent = self.last_agent + 1
    ui.table_of_units:add_unit(self.last_agent)
    return agent
end

function ObjectsManager:kill_agent(index)
    self:remove_agent(index)
end

function ObjectsManager:remove_agent(index)
    GAME_UI.table_of_units:remove_unit(index)
    self.agents[index] = nil
end


function ObjectsManager:update()
    local agents_to_delete = {}
    local agents_to_create = {}

    for _, agent in pairs(self.agents) do
        local responce = agent.character:update()
        if responce == nil then
            agent.ai:update(agent.character)
        elseif responce.type == "death" then
            table.insert(agents_to_delete, _)
        elseif responce.type == "new_agent" then
            table.insert(agents_to_create, responce)
        end
    end

    for k, v in pairs(agents_to_delete) do
        self:kill_agent(v)
    end
    for k, v in pairs(agents_to_create) do
        self:new_agent(GAME_UI, v.template, v.position, v.home)
    end
end

return ObjectsManager