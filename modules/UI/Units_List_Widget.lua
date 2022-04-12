local UnitLine = require "modules.UI.Unit_Line"


local UnitsList = {}
UnitsList.__index = UnitsList

function UnitsList:new()
    _ = {}
    _.view = milky.panel
        :new(milky, nil, nil, nil)
        :position(20, 20)
        :size(550, 550)
        :toggle_background()
        :toggle_border()
        :toggle_hidden()
    _.units = {}
    _.num_of_units = 0
    setmetatable(_, UnitsList)
    return _
end

function UnitsList:toggle_display()
    self.view:toggle_hidden()
end

function UnitsList:add_unit(index)
    self.units[index] = UnitLine:new(self.view, self.num_of_units)
    self.num_of_units = self.num_of_units + 1
end

---draws table of agents, according to data.
---@param collection_of_agents Agent[]
function UnitsList:draw(collection_of_agents)
    for i, line in pairs(self.units) do
        local agent = collection_of_agents[i]
        line:load_data(agent.agent, agent.ai.current_instruction.name)
    end

    self.view:draw()
end

return UnitsList