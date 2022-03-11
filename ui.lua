function init_ui()
    milky.render_rectangles = false
    camera = {}
    camera.x = 0
    camera.y = 0

    
    -- camera setup
    cam = {0, 0}
    
    map_control_ui = milky.panel:new(milky, nil, nil, nil)
        :position(0, 0)
        :size(602, 600)
        :toogle_background()
    
    -- interface init
    main_ui = milky.panel:new(milky, nil, nil, nil)
        :position(602,0)
        :size(198, 600)
        :toogle_background()
    
    
    gold_widget = milky.panel:new(milky, main_ui)
        :position(3, 3)
        :size(192, 54)
        :toogle_border()
        
        wealth_label = milky.panel:new(milky, gold_widget, 'TREASURY'):position(5, 6)
        wealth_widget = milky.panel:new(milky, gold_widget, "???", nil):position(150, 6)
        hunt_label = milky.panel:new(milky, gold_widget, 'HUNT INVESTED'):position(5, 26)
        hunt_widget = milky.panel:new(milky, gold_widget, "???", nil):position(150, 26)
    
    
    invest_widget = milky.panel:new(milky, main_ui)
        :position(3, 60)
        :size(192, 100)
        :toogle_border()
        
        income_invest_label = milky.panel:new(milky, invest_widget, 'ROYAL INVESTMENTS'):position(4, 5)
        
        treasury_invest_body, treasury_invest_value = create_invest_row(invest_widget, "TREASURY", castle.budget.treasury)
        hunt_invest_body, hunt_invest_value = create_invest_row(invest_widget, "HUNT", castle.budget.hunt)
        treasury_invest_body:position(10, 35)
        hunt_invest_body:position(10, 55)
    
    
    rewards_widget = milky.panel:new(milky, main_ui)
        :position(3, 163)
        :size(192, 70)
        :toogle_border()
        
        rewards_label = milky.panel:new(milky, rewards_widget, 'REWARDS'):position(4, 5)
        
        rewards_label_rat = milky.panel:new(milky, rewards_widget, 'RAT'):position(10, 35)
        rewards_label_rat_value = milky.panel:new(milky, rewards_widget, '10'):position(50, 35)

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
    
    tax_widget = milky.panel:new(milky, main_ui)
        :position(3, 236)
        :size(192, 70)
        :toogle_border()
        
        tax_label = milky.panel:new(milky, tax_widget, 'TAXES'):position(4, 5)
        
        inc_tax_label = milky.panel:new(milky, tax_widget, 'INCOME TAX'):position(10, 35)
        inc_tax_value = milky.panel:new(milky, tax_widget, '0%'):position(120, 35)
    
    
    hire_button = milky.panel:new(milky, main_ui)
        :position(3, 500)
        :size(192, 24)
        :button(milky, function (self, button) hire_hero() end)
        :toogle_border()
        :toogle_background()
    hire_button_label = milky.panel:new(milky, hire_button, "HIRE A HERO (100)"):position(5, 2)
    

    add_hunt_budget_button = milky.panel:new(milky, main_ui)
        :position(3, 527)
        :size(192, 24)
        :button(milky, function (self, button) add_hunt_budget() end)
        :toogle_border()
        :toogle_background()
    add_hunt_budget_label = milky.panel:new(milky, add_hunt_budget_button, "ADD HUNT MONEY (100)"):position(5, 2)



    function create_invest_row(parent, label, it)
        local body = milky.panel:new(milky, parent):size(187, 25):position(0, 0)
        
        local label = milky.panel:new(milky, body, label):position(0, 5):size(80, 17)
        local value = milky.panel:new(milky, body, '???'):position(120, 5):size(35, 17)
        local bd = milky.panel:new(milky, body, " -")
            :position(90, 5)
            :size(15, 15)
            :button(milky, function (self, button) dec_inv(it) end)
            :toogle_border()
            :toogle_background()
        local bi = milky.panel:new(milky, body, " +")
            :position(160, 5)
            :size(15, 15)
            :button(milky, function (self, button) inc_inv(it) end)
            :toogle_border()
            :toogle_background()
        
        return body, value
    end


    -- draw loop

    PRESSED_ON_MAP = false
    ORIGIN_OF_PRESSING = {0, 0}
    HOVER_ON_MAP = false
    ZONE_SELECTION = false

    function love.draw()    
        love.graphics.setColor(1, 1, 0)
        local grid_size = globals.CONSTANTS.GRID_SIZE

        for i = 1, last_food - 1 do
            if food_cooldown[i] == 0 then
                love.graphics.setColor(1, 0, 0)
            else 
                love.graphics.setColor(0.3, 0, 0)
            end
            
            local c_x = food_pos[i].x * grid_size + grid_size / 2
            local c_y = food_pos[i].y * grid_size + grid_size / 2
            love.graphics.circle('line', c_x, c_y, 3)
        end

        love.graphics.setColor(1, 1, 0)
        for i = 1, last_char - 1 do
            if (ALIVE_CHARS[i]) then
                love.graphics.circle('line', chars_x[i], chars_y[i], 2)
            end
        end
        
        love.graphics.setColor(1, 1, 0)
        for _, building in pairs(buildings) do
            local tmp = building:get_cell()
            love.graphics.rectangle('line', tmp.x * grid_size, tmp.y * grid_size, grid_size, grid_size)
        end
        
        
        for q, zone in pairs(ZONES) do
            local i, j, k, h = zone.x1, zone.y1, zone.x2, zone.y2
            love.graphics.setColor(0, 1, 0, 0.1)
            love.graphics.rectangle('fill', i * grid_size - camera.x, j * grid_size - camera.y, -(i - k) * grid_size - camera.x, -(j - h) * grid_size - camera.y)
            love.graphics.setColor(0, 1, 0, 0.6)
            love.graphics.rectangle('line', i * grid_size - camera.x, j * grid_size - camera.y, -(i - k) * grid_size - camera.x, -(j - h) * grid_size - camera.y)

            local c1, c2 = (i + k) / 2, (j + h) / 2
            love.graphics.setColor(0, 1, 0, 0.95)
            love.graphics.print('hunt', c1 * grid_size - 20, c2 * grid_size - 7)
        end
        
        
        local x, y = love.mouse.getPosition()

        draw_on_map_ui(x, y)

        love.graphics.setColor(1, 1, 0)
        main_ui:draw()
        
    end

    function love.mousepressed(x, y, button, istouch)
        if not PRESSED_ON_MAP then
            milky:onClick(x, y, button)
        end
        press_on_map_ui(x, y)
    end

    function love.mousereleased(x, y, button, istouch)
        if not PRESSED_ON_MAP then
            milky:onRelease(x, y, button)
        end
        release_on_map_ui(x, y)
        PRESSED_ON_MAP = false
    end

    function love.mousemoved(x, y, dx, dy, istouch)
        if not PRESSED_ON_MAP then
            milky:onHover(x, y)
        end
        hover_on_map_ui(x, y)
    end

    function draw_on_map_ui(x, y)
        if not main_ui:xy_in_rect_test(x, y) or PRESSED_ON_MAP then
            local grid_size = globals.CONSTANTS.GRID_SIZE
            local tmp = {
            x = x + camera.x,
            y = y + camera.y}
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

    function hover_on_map_ui(x, y)
        if not main_ui:xy_in_rect_test(x, y) then
            HOVER_ON_MAP = true
        else
            HOVER_ON_MAP = true
            -- HOVER_ON_MAP = false
            -- PRESSED_ON_MAP = false
        end
    end

    function press_on_map_ui(x, y)
        if not main_ui:xy_in_rect_test(x, y) then
            PRESSED_ON_MAP = true
            ORIGIN_OF_PRESSING = {x, y}
        else
            -- HOVER_ON_MAP = false
            -- PRESSED_ON_MAP = false
        end
    end

    function release_on_map_ui(x, y)  
        if ZONE_SELECTION and PRESSED_ON_MAP then
            local a = convert_coord_to_cell({x=x, y=y});
            local b = convert_coord_to_cell({x-ORIGIN_OF_PRESSING[1], y=ORIGIN_OF_PRESSING[2]})
            new_zone(nil, b.x, b.y, a.x, a.y)
        end
        PRESSED_ON_MAP = false
    end


end