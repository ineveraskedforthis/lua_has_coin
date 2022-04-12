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
    local line = UnitLine:new(self.view, self.num_of_units)
    self.num_of_units = self.num_of_units + 1
    self.units[index] = line
end

function UnitsList:remove_unit(index)
    if self.units[index] ~= nil then
        local temp = self.units[index].line_number
        self.units[index]:destroy()
        self.units[index] = nil
        for i, line in pairs(self.units) do
            if line.line_number > temp then
                line:shift_line_up()
            end
        end
        self.num_of_units = self.num_of_units - 1
    end
end

---draws table of agents, according to data.
---@param collection_of_agents Agent[]
function UnitsList:draw(collection_of_agents)
    for i, line in pairs(self.units) do
        local agent = collection_of_agents[i]
        if agent ~= nil then
            line:load_data(agent.character, agent.ai.current_instruction.name)
        end
    end
    self.view:draw()
end

return UnitsList