---@class UI
---@field camera Position
UI = {}
UI.__index = UI

---Creates an UI object
---@param render_rectangles boolean
---@return UI
function UI:new(render_rectangles)
    local _ = {
        camera = {x = 0, y = 0},
        milky = milky,
        PRESSED_ON_MAP = false,
        ORIGIN_OF_PRESSING = {0, 0},
        HOVER_ON_MAP = false,
        ZONE_SELECTION = false,
    }
    setmetatable(_, self)
    _.milky.render_rectangles = render_rectangles    
    _:set_up()
    return _
end

function UI:set_up()
    self.map_control_ui = milky.panel
        :new(milky, nil, nil, nil)
        :position(0, 0)
        :size(602, 600)
        :toogle_background()

    self.main_ui = milky.panel
        :new(milky, nil, nil, nil)
        :position(602,0)
        :size(198, 600)
        :toogle_background()

    self:set_up_budget_block()
    self:set_up_hire_block()
    self:set_up_invest_block()
    self:set_up_reward_block()
    self:set_up_tax_block()

    self:set_up_units_table()
end

function UI:set_up_units_table()
    self.table_of_units = milky.panel
        :new(milky, nil, nil, nil)
        :position(20, 20)
        :size(550, 550)
        :toogle_background()
        :toogle_border()
        -- :toogle_hidden()
    self.lines_of_units = {}
    for i = 1, 15 do
        table.insert(self.lines_of_units, #self.lines_of_units + 1, UnitLine:new(self.table_of_units, i))
    end
end

UnitLine = {}
UnitLine.__index = UnitLine

function UnitLine:new(parent, line_number)
    _ = {}
    _.ui_element = milky.panel
        :new(milky, parent)
        :position(10, 30 * (line_number - 1) + 10)
        :size(530, 25)
        :toogle_border()
    
    _.name_label = milky.panel
        :new(milky, _.ui_element)
        :position(5, 4)
        :size(50, 20)
        :update_label("name")
    
    _.wealth_label = milky.panel
        :new(milky, _.ui_element)
        :position(100, 4)
        :size(50, 20)
        :update_label("wealth")

    _.tiredness_label = milky.panel
        :new(milky, _.ui_element)
        :position(150, 4)
        :size(50, 20)
        :update_label("tired")

    
    _.hunger_label = milky.panel
        :new(milky, _.ui_element)
        :position(200, 4)
        :size(50, 20)
        :update_label("hunger")

    _.sell_food_utility_label = milky.panel
        :new(milky, _.ui_element)
        :position(300, 4)
        :size(50, 20)
        :update_label("sell util")

    _.order_label = milky.panel
        :new(milky, _.ui_element)
        :position(350, 4)
        :size(50, 20)
        :update_label("order")
    
    setmetatable(_, UnitLine)
    return _
end

---loads character data into line
---@param character Character
function UnitLine:load_data(character)
    self.name_label:update_label(character.name)
    self.wealth_label:update_label(character.wealth)
    self.tiredness_label:update_label(character.tiredness)
    self.hunger_label:update_label(character.hunger)
    local utili = Calculate_Utility(character)
    self.sell_food_utility_label:update_label(utili[5])
    self.order_label:update_label(character.order)
end

function UI:set_up_budget_block()
    self.gold_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 3)
        :size(192, 54)
        :toogle_border()
    self.wealth_label = milky.panel
        :new(milky, self.gold_widget, 'TREASURY')
        :position(5, 6)
    self.wealth_widget = milky.panel
        :new(milky, self.gold_widget, "???", nil)
        :position(150, 6)
    self.hunt_label = milky.panel
        :new(milky, self.gold_widget, 'HUNT INVESTED')
        :position(5, 26)
    self.hunt_widget = milky.panel
        :new(milky, self.gold_widget, "???", nil)
        :position(150, 26)
end

function UI:set_up_invest_block()
    self.invest_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 60)
        :size(192, 100)
        :toogle_border()
    income_invest_label = milky.panel
        :new(milky, self.invest_widget, 'ROYAL INVESTMENTS')
        :position(4, 5) 
    treasury_invest_body, treasury_invest_value = create_invest_row(self.invest_widget, "TREASURY", "treasury")
    hunt_invest_body, hunt_invest_value = create_invest_row(self.invest_widget, "HUNT", "hunt")
    treasury_invest_body
        :position(10, 35)
    hunt_invest_body
        :position(10, 55)
    add_hunt_budget_button = milky.panel
        :new(milky, self.main_ui)
        :position(3, 527)
        :size(192, 24)
        :button(milky, function (self, button) castle.add_hunt_budget() end)
        :toogle_border()
        :toogle_background()
    add_hunt_budget_label = milky.panel
        :new(milky, add_hunt_budget_button, "ADD HUNT MONEY (100)")
        :position(5, 2)
end

function UI:set_up_reward_block()
    rewards_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 163)
        :size(192, 70)
        :toogle_border()
    rewards_label = milky.panel
        :new(milky, rewards_widget, 'HUNTING LOG')
        :position(4, 5)
    rewards_label_rat = milky.panel
        :new(milky, rewards_widget, 'RAT')
        :position(10, 35)
    rewards_label_rat_value = milky.panel
        :new(milky, rewards_widget, '10')
        :position(50, 35)
end


function UI:set_up_tax_block()
    tax_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 236)
        :size(192, 70)
        :toogle_border()
    
    tax_label = milky.panel
        :new(milky, tax_widget, 'TAXES')
        :position(4, 5)    
    inc_tax_label = milky.panel
        :new(milky, tax_widget, 'INCOME TAX')
        :position(10, 35)
    inc_tax_value = milky.panel
        :new(milky, tax_widget, '0%')
        :position(120, 35)
end

function UI:set_up_hire_block()
    hire_button = milky.panel:new(milky, self.main_ui)
        :position(3, 500)
        :size(192, 24)
        :button(milky, function (self, button) castle.hire_hero() end)
        :toogle_border()
        :toogle_background()
    hire_button_label = milky.panel:new(milky, hire_button, "HIRE A HERO (100)"):position(5, 2)
end


function UI:draw()
    love.graphics.setColor(1, 1, 0)
    local grid_size = globals.CONSTANTS.GRID_SIZE

    for _, food_obj in pairs(food) do
        if food_obj.cooldown == 0 then
            love.graphics.setColor(0.8, 0, 0)
        else 
            love.graphics.setColor(0.3, 0, 0)
        end
        local c_x = food_obj.cell.x * grid_size + grid_size / 2
        local c_y = food_obj.cell.y * grid_size + grid_size / 2
        love.graphics.circle('line', c_x, c_y, 2)
    end

    love.graphics.setColor(1, 1, 0)
    for _, agent in pairs(agents) do
        local pos = agent.agent:pos()

        self.lines_of_units[_]:load_data(agent.agent)

        love.graphics.circle('line', pos.x, pos.y, 2)
        love.graphics.print(agent.agent.name, pos.x + 2, pos.y - 15)
        love.graphics.print(tostring(agent.agent:get_hunger()), pos.x + 2, pos.y + 2)
        love.graphics.print(tostring(agent.agent:get_tiredness()), pos.x + 2, pos.y + 15)
    end

    love.graphics.setColor(1, 1, 0)
    for _, building in pairs(buildings) do
        local tmp = building:cell()
        local pos = building:pos()
        love.graphics.rectangle('line', tmp.x * grid_size, tmp.y * grid_size, grid_size, grid_size)
        love.graphics.print(tostring(building.wealth), pos.x + 2, pos.y + 10)
        love.graphics.print(tostring(building.wealth_before_tax), pos.x + 2, pos.y + 20)
    end

    love.graphics.rectangle('line', castle:get_cell().x * grid_size, castle:get_cell().x * grid_size, grid_size, grid_size)
    love.graphics.rectangle('line', castle:get_cell().x * grid_size + 3, castle:get_cell().x * grid_size + 3, grid_size - 6, grid_size - 6)
    
    for q, zone in pairs(ZONES) do
        local i, j, k, h = zone.x1, zone.y1, zone.x2, zone.y2
        love.graphics.setColor(0, 1, 0, 0.1)
        love.graphics.rectangle('fill', i * grid_size - self.camera.x, j * grid_size - self.camera.y, -(i - k) * grid_size - self.camera.x, -(j - h) * grid_size - self.camera.y)
        love.graphics.setColor(0, 1, 0, 0.6)
        love.graphics.rectangle('line', i * grid_size - self.camera.x, j * grid_size - self.camera.y, -(i - k) * grid_size - self.camera.x, -(j - h) * grid_size - self.camera.y)

        local c1, c2 = (i + k) / 2, (j + h) / 2
        love.graphics.setColor(0, 1, 0, 0.95)
    end
    
    
    local x, y = love.mouse.getPosition()

    self:draw_on_map_ui(x, y)

    love.graphics.setColor(1, 1, 0)
    self.main_ui:draw()
    self.table_of_units:draw()
end


function UI:draw_on_map_ui(x, y)
    if not self.main_ui:xy_in_rect_test(x, y) or PRESSED_ON_MAP then
        local grid_size = globals.CONSTANTS.GRID_SIZE
        local tmp = {
        x = x + self.camera.x,
        y = y + self.camera.y}
        local b = convert_coord_to_cell(tmp);

        if PRESSED_ON_MAP then
            love.graphics.setColor(0, 1, 1, 1)
        else 
            love.graphics.setColor(1, 1, 1, 0.2)
        end

        if ZONE_SELECTION then

            love.graphics.rectangle('line', b.x * grid_size, b.y * grid_size, grid_size, grid_size)

            if PRESSED_ON_MAP then
                love.graphics.setColor(0, 1, 0, 0.2)
                local a = convert_coord_to_cell({x = ORIGIN_OF_PRESSING[1], y = ORIGIN_OF_PRESSING[2]})
                love.graphics.rectangle('fill', a.x * grid_size, a.y * grid_size, (b.x - a.x) * grid_size, (b.y - a.y) * grid_size)
            end

        end
    end
end


function UI:hover_on_map_ui(x, y)
    if not self.main_ui:xy_in_rect_test(x, y) then
        HOVER_ON_MAP = true
    else
        HOVER_ON_MAP = true
        -- HOVER_ON_MAP = false
        -- PRESSED_ON_MAP = false
    end
end

function UI:press_on_map_ui(x, y)
    if not self.main_ui:xy_in_rect_test(x, y) then
        PRESSED_ON_MAP = true
        ORIGIN_OF_PRESSING = {x, y}
    else
        -- HOVER_ON_MAP = false
        -- PRESSED_ON_MAP = false
    end
end

function UI:release_on_map_ui(x, y)  
    if ZONE_SELECTION and PRESSED_ON_MAP then
        local a = convert_coord_to_cell({x=x, y=y});
        local b = convert_coord_to_cell({x-ORIGIN_OF_PRESSING[1], y=ORIGIN_OF_PRESSING[2]})
        -- new_zone(nil, b.x, b.y, a.x, a.y)
    end
    PRESSED_ON_MAP = false
end


function love.mousepressed(x, y, button, istouch)
    if not PRESSED_ON_MAP then
        milky:onClick(x, y, button)
    end
    game_ui:press_on_map_ui(x, y)
end

function love.mousereleased(x, y, button, istouch)
    if not PRESSED_ON_MAP then
        milky:onRelease(x, y, button)
    end
    game_ui:release_on_map_ui(x, y)
    PRESSED_ON_MAP = false
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not PRESSED_ON_MAP then
        milky:onHover(x, y)
    end
    game_ui:hover_on_map_ui(x, y)
end




    function new_zone_callback (self, button)
        ZONE_SELECTION = not ZONE_SELECTION;
        ZONE_DELETION = false
        if ZONE_SELECTION then
            new_zone_button:setBackgroundColor({0, 1, 0, 0.6}, {0, 1, 0, 0.3}, {0, 0.5, 0, 0.2})
        else
            new_zone_button:setBackgroundColor({0, 0.5, 0, 0.2}, {0, 1, 0, 0.3}, {0, 1, 0, 0.6})
        end
    end

    function delete_zone_callback (self, button)
        ZONE_DELETION = not ZONE_DELETION;
        ZONE_SELECTION = false
        if ZONE_DELETION then
            delete_zone_button:setBackgroundColor({1, 0, 0, 0.6}, {1, 0, 0, 0.3}, {0.5, 0, 0, 0.2})
        else
            delete_zone_button:setBackgroundColor({0.5, 0, 0, 0.2}, {1, 0, 0, 0.3}, {1, 0, 0, 0.6})
        end
    end

    new_zone_button = milky.panel:new(milky, rewards_widget)
        :position(100, 5)
        :size(50, 20)
        :button(milky, new_zone_callback)
        :toogle_border()
        :setBorderColor({0, 1, 0, 0.7}, {0, 1, 0, 1.0}, {0, 1, 0, 1.0})
        :setBackgroundColor({0, 1, 0, 0.2}, {0, 1, 0, 0.3}, {0, 1, 0, 0.6})
        :toogle_background()

    delete_zone_button = milky.panel:new(milky, rewards_widget)
        :position(100, 35)
        :size(50, 20)
        :button(milky, delete_zone_callback)
        :toogle_border()
        :setBorderColor({1, 0, 0, 0.7}, {1, 0, 0, 1.0}, {1, 0, 0, 1.0})
        :setBackgroundColor({1, 0, 0, 0.2}, {1, 0, 0, 0.3}, {1, 0, 0, 0.6})
        :toogle_background()










---comment
---@param parent table
---@param label string
---@param it "hunt"|"treasury"
---@return table
---@return table
function create_invest_row(parent, label, it)
    local body = milky.panel:new(milky, parent):size(187, 25):position(0, 0)
    local label = milky.panel:new(milky, body, label):position(0, 5):size(80, 17)
    local value = milky.panel:new(milky, body, '???'):position(120, 5):size(35, 17)
    local bd = milky.panel:new(milky, body, " -")
        :position(90, 5)
        :size(15, 15)
        :button(milky, function (self, button) castle:dec_inv(it) end)
        :toogle_border()
        :toogle_background()
    local bi = milky.panel:new(milky, body, " +")
        :position(160, 5)
        :size(15, 15)
        :button(milky, function (self, button) castle:inc_inv(it) end)
        :toogle_border()
        :toogle_background()
    return body, value
end


return UI

