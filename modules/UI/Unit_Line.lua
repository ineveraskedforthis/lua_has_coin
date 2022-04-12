local UnitLine = {}
UnitLine.__index = UnitLine

function UnitLine:new(parent, line_number)
    _ = {}
    _.line_number = line_number
    _.ui_element = milky.panel
        :new(milky, parent)
        :position(10, 30 * (line_number) + 10)
        :size(530, 25)
        :toggle_border()
    
    _.name_label = milky.panel
        :new(milky, _.ui_element)
        :position(5, 4)
        :size(50, 20)
        :update_label("name")
    
    _.wealth_label = milky.panel
        :new(milky, _.ui_element)
        :position(70, 4)
        :size(50, 20)
        :update_label("wealth")

    _.tiredness_label = milky.panel
        :new(milky, _.ui_element)
        :position(120, 4)
        :size(50, 20)
        :update_label("tired")

    
    _.hunger_label = milky.panel
        :new(milky, _.ui_element)
        :position(170, 4)
        :size(50, 20)
        :update_label("hunger")

    _.order_label = milky.panel
        :new(milky, _.ui_element)
        :position(270, 4)
        :size(50, 20)
        :update_label("order")

    _.instruction_label = milky.panel
        :new(milky, _.ui_element)
        :position(400, 4)
        :size(50, 20)
        :update_label("instruction")
    
    setmetatable(_, UnitLine)
    return _
end

function UnitLine:shift_line_up()
    self.line_number = self.line_number - 1
    self.ui_element:position(10, 30 * (self.line_number) + 10)
end
function UnitLine:destroy()
    self.ui_element:destroy(milky)
end

---loads character data into line
---@param character Character
function UnitLine:load_data(character, instruction)
    self.name_label:update_label(character.name)
    self.wealth_label:update_label(character.wealth)
    self.tiredness_label:update_label(character.tiredness)
    self.hunger_label:update_label(character.hunger)
    self.order_label:update_label(character.order.name)
    self.instruction_label:update_label(instruction)
end

return UnitLine