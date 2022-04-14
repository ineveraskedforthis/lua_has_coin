local Units_List_Widget = require "modules.UI.Units_List_Widget"
---@class UI
---@field camera Position
---@field main_ui table
---@field lines_of_units table
---@field table_of_buildings table
---@field table_of_units table
---@field building_indices table
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
        :new(milky)
        :position(0, 0)
        :size(602, 600)
        :toggle_background()

    self.main_ui = milky.panel
        :new(milky)
        :position(602,0)
        :size(198, 600)
        :toggle_background()

    local list_button_size = 94
    local list_button_h = 25

    self.toggle_character_screen_button = milky.panel
        :new(milky, self.main_ui)
        :position(3, 520)
        :size(list_button_size, list_button_h)
        :toggle_border()
        :update_label("Characters")
        :button(milky, function (self, button) TOGGLE_CHAR_SCREEN() end)
        :toggle_background()
        :center_text()

    self.toggle_buildings_screen_button = milky.panel
        :new(milky, self.main_ui)
        :position(list_button_size + 7, 520)
        :size(list_button_size, list_button_h)
        :toggle_border()
        :update_label("Buildings")
        :button(milky, function (self, button) toggle_buildings_screen() end)
        :toggle_background()
        :center_text()

    self:set_up_budget_block()
    self:set_up_hire_block()
    self:set_up_invest_block()
    self:set_up_reward_block()
    self:set_up_tax_block()
    self:set_up_speed_control()
    self:set_up_units_table()
    self:set_up_buildings_table()
end

function TOGGLE_CHAR_SCREEN()
    GAME_UI.table_of_units:toggle_display()
end

function UI:set_up_speed_control()
    local speed_control_frame = milky.panel
        :new(milky, self.main_ui)
        :position(3, 550)
        :size(192, 48)
        :toggle_background()
    
    local label = milky.panel
        :new(milky, speed_control_frame, "Game speed:")
        :position(0, 0)
    SPEED_LABEL = milky.panel
        :new(milky, speed_control_frame, "0")
        :position(150, 0)

    local button_h = 28
    local button_w = 48
    local button_top = 20
    local speed_0 = milky.panel
        :new(milky, speed_control_frame, "0")
        :position(button_w * 0, button_top)
        :size(button_w, button_h)
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) UPDATE_GAME_SPEED(0) SPEED_LABEL:update_label("0") end)
        :center_text()
    local speed_1 = milky.panel
        :new(milky, speed_control_frame, "1")
        :position(button_w * 1, button_top)
        :size(button_w, button_h)
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) UPDATE_GAME_SPEED(1) SPEED_LABEL:update_label("1") end)
        :center_text()
    local speed_2 = milky.panel
        :new(milky, speed_control_frame, "2")
        :position(button_w * 2, button_top)
        :size(button_w, button_h)
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) UPDATE_GAME_SPEED(8) SPEED_LABEL:update_label("2") end)
        :center_text()
    local speed_3 = milky.panel
        :new(milky, speed_control_frame, "3")
        :position(button_w * 3, button_top)
        :size(button_w, button_h)
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) UPDATE_GAME_SPEED(64) SPEED_LABEL:update_label("3") end)
        :center_text()
end

function UI:set_up_units_table()
    self.table_of_units = Units_List_Widget:new()
end


function UI:set_up_buildings_table()
    self.table_of_buildings = milky.panel
        :new(milky, nil, nil, nil)
        :position(20, 20)
        :size(550, 550)
        :toggle_background()
        :toggle_border()
        :toggle_hidden()
    self.building_indices = {}
    local height = 30
    local block1 = 50
    local block_size = 50
    local pad = 15
    for i = 1, 15 do
        self.building_indices[i] = milky.panel 
            :new(milky, self.table_of_buildings)
            :position(10, (height + 5) * (i - 1) + 10)
            :size(530, height)
            :toggle_border()
        self.building_indices[i].label = milky.panel
            :new(milky, self.building_indices[i], "label")
            :position(5, 0)
            :size(block_size, height)
            :center_text()
        self.building_indices[i].label_price_food = milky.panel
            :new(milky, self.building_indices[i])
            :position(block1 + pad, 0)
            :size(block_size + pad * 2, height)
            :toggle_border()
        self.building_indices[i].label_price_food.buy = milky.panel 
            :new(milky, self.building_indices[i].label_price_food, "buy")
            :position(0, 0)
            :size(block_size, math.floor(height / 2))
            :toggle_border()
            :center_text()
        self.building_indices[i].label_price_food.sell = milky.panel 
            :new(milky, self.building_indices[i].label_price_food, "sell")
            :position(0, math.floor(height / 2))
            :size(block_size, math.floor(height / 2))
            :toggle_border()
            :center_text()
        self.building_indices[i].label_price_food.stash = milky.panel 
            :new(milky, self.building_indices[i].label_price_food, "stash")
            :position(block_size, 0)
            :size(pad * 2, height)
            :toggle_border()
            :center_text()
        self.building_indices[i].label_price_potion = milky.panel
            :new(milky, self.building_indices[i])
            :position(block1 + pad * 2 + block_size + pad * 2, 0)
            :size(block_size + pad * 2, height)
            :toggle_border()
        self.building_indices[i].label_price_potion.buy = milky.panel 
            :new(milky, self.building_indices[i].label_price_potion, "buy")
            :position(0, 0)
            :size(block_size, math.floor(height / 2))
            :toggle_border()
            :center_text()
        self.building_indices[i].label_price_potion.sell = milky.panel 
            :new(milky, self.building_indices[i].label_price_potion, "sell")
            :position(0, math.floor(height / 2))
            :size(block_size, math.floor(height / 2))
            :toggle_border()
            :center_text()
        self.building_indices[i].label_price_potion.stash = milky.panel 
            :new(milky, self.building_indices[i].label_price_potion, "stash")
            :position(block_size, 0)
            :size(pad * 2, height)
            :toggle_border()
            :center_text()
    end
    
        -- :size()
    -- self.lines_of_units = {}
    -- for i = 1, 15 do
    --     table.insert(self.lines_of_units, #self.lines_of_units + 1, UnitLine:new(self.table_of_units, i))
    -- end
end

function toggle_buildings_screen()
    GAME_UI.table_of_buildings:toggle_hidden()
end

function UI:set_up_budget_block()
    self.gold_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 3)
        :size(192, 54)
        :toggle_border()
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
        :toggle_border()
    income_invest_label = milky.panel
        :new(milky, self.invest_widget, 'ROYAL INVESTMENTS')
        :position(4, 5) 
    treasury_invest_body, treasury_invest_value = create_invest_row(self.invest_widget, "TREASURY", "treasury")
    hunt_invest_body, hunt_invest_value = create_invest_row(self.invest_widget, "HUNT", "hunt")
    treasury_invest_body
        :position(10, 35)
    hunt_invest_body
        :position(10, 55)
    -- add_hunt_budget_button = milky.panel
    --     :new(milky, self.main_ui)
    --     :position(3, 527)
    --     :size(192, 24)
    --     :button(milky, function (self, button) castle.add_hunt_budget() end)
    --     :toggle_border()
    --     :toggle_background()
    -- add_hunt_budget_label = milky.panel
    --     :new(milky, add_hunt_budget_button, "ADD HUNT MONEY (100)")
    --     :position(5, 2)
end

function UI:set_up_reward_block()
    rewards_widget = milky.panel
        :new(milky, self.main_ui)
        :position(3, 163)
        :size(192, 70)
        :toggle_border()
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
        :size(192, 74)
        :toggle_border()
    
    tax_label = milky.panel
        :new(milky, tax_widget, 'TAXES')
        :position(4, 5)    
    local tax_label = milky.panel
        :new(milky, tax_widget, 'INCOME TAX')
        :position(10, 35)
    tax_value = milky.panel
        :new(milky, tax_widget, '0%')
        :position(130, 35)
    local decrease_tax_b = milky.panel
        :new(milky, tax_widget, "-")
        :position(100, 35)
        :size(15, 15)
        :center_text()
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) castle:dec_tax() end)
    local increase_tax_b = milky.panel
        :new(milky, tax_widget, "+")
        :position(170, 35)
        :size(15, 15)
        :center_text()
        :toggle_border()
        :toggle_background()
        :button(milky, function(self, button) castle:inc_tax() end)
end

function UI:set_up_hire_block()
    self.offices_block = milky.panel
        :new(milky, self.main_ui)
        :position(3, 313)
        :size(192, 200)
        :toggle_border()

    local label = milky.panel
        :new(milky, self.offices_block, "Tax Collectors")
        :position(4, 5)
    
    tax_collectors_list = {}
    tax_collectors_payment = {}

    for i = 1, 10 do
        tax_collectors_list[i] = milky.panel
            :new(milky, self.offices_block, "- Empty")
            :position(7, i * 20 + 5)
            :toggle_hidden()
        tax_collectors_payment[i] = milky.panel
            :new(milky, tax_collectors_list[i], "0")
            :position(100, 0)
    end
    local hire_tax_collector_button = milky.panel
        :new(milky, self.offices_block, "+")
        :position(100, 5)
        :size(14, 14)
        :toggle_border()
        :toggle_background()
        :center_text()
        :button(milky, function (self, button) castle:open_tax_collector_position() show_office_position(castle.open_tax_collector_positions) end)
    local fire_tax_collector_button = milky.panel
        :new(milky, self.offices_block, "-")
        :position(130, 5)
        :size(14, 14)
        :toggle_border()
        :toggle_background()
        :center_text()
        :button(milky, function (self, button) castle:close_tax_collector_position() hide_office_position(castle.open_tax_collector_positions + 1) end)

    -- hire_button = milky.panel:new(milky, self.main_ui)
    --     :position(3, 500)
    --     :size(192, 24)
    --     :button(milky, function (self, button) castle.hire_hero() end)
    --     :toggle_border()
    --     :toggle_background()
    -- hire_button_label = milky.panel:new(milky, hire_button, "HIRE A HERO (100)"):position(5, 2)
end

function hide_office_position(i)
    tax_collectors_list[i]:hide()
end

function show_office_position(i)
    tax_collectors_list[i]:unhide()
end


function UI:draw()

    love.graphics.setColor(1, 1, 0)
    local grid_size = globals.CONSTANTS.GRID_SIZE

    for _, t in pairs(castle.payment_timer) do
        tax_collectors_payment[_]:update_label(t)
    end

    for _, food_obj in pairs(food) do
        if food_obj.cooldown == 0 then
            love.graphics.setColor(0.8, 0, 0)
        else 
            love.graphics.setColor(0.3, 0, 0)
        end
        local center = food_obj.cell:center()
        love.graphics.circle('line', center.x, center.y, 2)
    end

    love.graphics.setColor(1, 1, 0)
    for _, agent in pairs(OBJ_MANAGER.agents) do
        local pos = agent.character:pos()
        love.graphics.circle('line', pos.x, pos.y, 2)
        love.graphics.print(agent.character.name, pos.x + 2, pos.y - 15)
        love.graphics.print(tostring(agent.character:get_hunger()), pos.x + 2, pos.y + 2)
        love.graphics.print(tostring(agent.character:get_tiredness()), pos.x + 2, pos.y + 15)
    end


    love.graphics.setColor(1, 1, 0)
    for _, building in pairs(buildings) do
        local tmp = building:cell()
        local pos = building:pos()
        love.graphics.rectangle('line', tmp.x * grid_size, tmp.y * grid_size, grid_size, grid_size)
        love.graphics.print(tostring(building.wealth), pos.x + 2, pos.y + 10)
        love.graphics.print(tostring(building.wealth_before_tax), pos.x + 2, pos.y + 20)
        -- love.graphics.print("buy   " .. tostring(math.floor(building._av_timer_buy[GOODS.FOOD])), pos.x + 40, pos.y + 10)
        -- love.graphics.print("sell  " .. tostring(math.floor(building._av_timer_sell[GOODS.FOOD])), pos.x + 40, pos.y + 20)
        -- love.graphics.print("stash " .. tostring(building:get_stash(GOODS.FOOD)), pos.x + 40, pos.y + 30)
        self.building_indices[_].label_price_food.buy:update_label(building:get_buy_price(GOODS.FOOD))
        self.building_indices[_].label_price_food.sell:update_label(building:get_sell_price(GOODS.FOOD))
        self.building_indices[_].label_price_food.stash:update_label(building:get_stash(GOODS.FOOD))
        self.building_indices[_].label_price_potion.buy:update_label(building:get_buy_price(GOODS.POTION))
        self.building_indices[_].label_price_potion.sell:update_label(building:get_sell_price(GOODS.POTION))
        self.building_indices[_].label_price_potion.stash:update_label(building:get_stash(GOODS.POTION))
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
    self.table_of_units:draw(OBJ_MANAGER.agents)
    self.table_of_buildings:draw()
end


function UI:draw_on_map_ui(x, y)
    if not self.main_ui:xy_in_rect_test(x, y) or PRESSED_ON_MAP then
        local grid_size = globals.CONSTANTS.GRID_SIZE
        local tmp = {
        x = x + self.camera.x,
        y = y + self.camera.y}
        local b = Cell:new_from_coordinate(tmp);

        if PRESSED_ON_MAP then
            love.graphics.setColor(0, 1, 1, 1)
        else 
            love.graphics.setColor(1, 1, 1, 0.2)
        end

        if ZONE_SELECTION then

            love.graphics.rectangle('line', b.x * grid_size, b.y * grid_size, grid_size, grid_size)

            if PRESSED_ON_MAP then
                love.graphics.setColor(0, 1, 0, 0.2)
                local a = Cell:new_from_coordinate({x = ORIGIN_OF_PRESSING[1], y = ORIGIN_OF_PRESSING[2]})
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
        local a = Cell:new_from_coordinate({x=x, y=y});
        local b = Cell:new_from_coordinate({x-ORIGIN_OF_PRESSING[1], y=ORIGIN_OF_PRESSING[2]})
        -- new_zone(nil, b.x, b.y, a.x, a.y)
    end
    PRESSED_ON_MAP = false
end


function love.mousepressed(x, y, button, istouch)
    if not PRESSED_ON_MAP then
        milky:onClick(x, y, button)
    end
    GAME_UI:press_on_map_ui(x, y)
end

function love.mousereleased(x, y, button, istouch)
    if not PRESSED_ON_MAP then
        milky:onRelease(x, y, button)
    end
    GAME_UI:release_on_map_ui(x, y)
    PRESSED_ON_MAP = false
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not PRESSED_ON_MAP then
        milky:onHover(x, y)
    end
    GAME_UI:hover_on_map_ui(x, y)
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
        :toggle_border()
        :setBorderColor({0, 1, 0, 0.7}, {0, 1, 0, 1.0}, {0, 1, 0, 1.0})
        :setBackgroundColor({0, 1, 0, 0.2}, {0, 1, 0, 0.3}, {0, 1, 0, 0.6})
        :toggle_background()

    delete_zone_button = milky.panel:new(milky, rewards_widget)
        :position(100, 35)
        :size(50, 20)
        :button(milky, delete_zone_callback)
        :toggle_border()
        :setBorderColor({1, 0, 0, 0.7}, {1, 0, 0, 1.0}, {1, 0, 0, 1.0})
        :setBackgroundColor({1, 0, 0, 0.2}, {1, 0, 0, 0.3}, {1, 0, 0, 0.6})
        :toggle_background()










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
    local bd = milky.panel:new(milky, body, "-")
        :position(90, 5)
        :size(15, 15)
        :button(milky, function (self, button) castle:dec_inv(it) end)
        :toggle_border()
        :toggle_background()
        :center_text()
    local bi = milky.panel:new(milky, body, "+")
        :position(160, 5)
        :size(15, 15)
        :button(milky, function (self, button) castle:inc_inv(it) end)
        :toggle_border()
        :toggle_background()
        :center_text()
    return body, value
end


return UI

