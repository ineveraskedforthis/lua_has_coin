---@diagnostic disable: trailing-space
local milky = require "milky"
local hunter = require "agent_types/hunter"
local tax_collector = require "agent_types/tax_collector"
local food_collector = require "agent_types/food_collector"
local rat = require "agent_types/rat"

milky.render_rectangles = false
camera = {}
camera.x = 0
camera.y = 0

function love.load()
    love.window.setMode(800, 600)
    grid_size = 10

    -- data structs init

    -- DEFINES
    CHANCE_FOR_A_POTION_TO_SPOIL = 0.0001
    
    -- flags
    map_build_flag = {}
    
    -- lists
    
    ALIVE_RATS = {}
    ALIVE_HEROES = {}
    ALIVE_CHARS = {}
    
    -- kingdom 
    kingdom_wealth = 0
    hunt_budget = 0
    
    REWARD = 10
    POTION_PRICE = 10
    FOOD_PRICE = 2

 
    
    INVESTMENT_TYPE = {}
    INVESTMENT_TYPE.TREASURY = 0
    INVESTMENT_TYPE.HUNT = 1
    
    BUDGET_RATIO = {}
    BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] = 100
    BUDGET_RATIO[INVESTMENT_TYPE.HUNT] = 0
    
    INCOME_TAX = 90

    
    -- character states

    
    CHAR_STATE = {}
    init_occupation_vars()
    
    -- responses
    CHANGE_HP_RESPONSE = {}
    CHANGE_HP_RESPONSE.DEAD = 0
    CHANGE_HP_RESPONSE.ALIVE = 1
    
    
    CHAR_ATTACK_RESPONSE = {}
    CHAR_ATTACK_RESPONSE.KILL = 0
    CHAR_ATTACK_RESPONSE.DAMAGE = 1
    CHAR_ATTACK_RESPONSE.NO_DAMAGE = 2
    
    
    ---- init arrays
    -- characters
    init_chars_arrays()
    init_food_array()
    
    -- buildings
    last_building = 1
    buildings_i = {}
    buildings_j = {}
    buildings_wealth_before_taxes = {}
    buildings_wealth_after_taxes = {}
    buildings_type = {}
    buildings_char_amount = {}
    buildings_stash = {}
    building_is_state_owned = {}
    
    BUILDING_TYPES = {}
    BUILDING_TYPES.ALCHEMIST = 0   
    BUILDING_TYPES.CASTLE = 1
    BUILDING_TYPES.RAT_LAIR = 2
    BUILDING_TYPES.FOOD_SHOP = 3
    
    
    -- game data
    
    kingdom_wealth = 500
    
    new_building(BUILDING_TYPES.CASTLE, 30, 30)
    local tmp = new_building(BUILDING_TYPES.ALCHEMIST, 37, 23)
    buildings_stash[tmp] = 200
    building_is_state_owned[tmp] = true

    new_building(BUILDING_TYPES.RAT_LAIR, 7, 8)    
    new_building(BUILDING_TYPES.RAT_LAIR, 3, 50)
    new_building(BUILDING_TYPES.RAT_LAIR, 53, 37)
    
    new_tax_collector()
    local t = new_hero(100)
    chars_occupation[t] = CHAR_OCCUPATION.FOOD_COLLECTOR
    
    
    for i = 1, 100 do
        for j = 1, 100 do
            if (map_build_flag[i] == nil) or (map_build_flag[i][j] == nil) then
                local dice = math.random()
                if dice > 0.9 then
                    new_food(i, j)
                end
            end
        end
    end
    
    
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
        
        treasury_invest_body, treasury_invest_value = create_invest_row(invest_widget, "TREASURY", INVESTMENT_TYPE.TREASURY)
        hunt_invest_body, hunt_invest_value = create_invest_row(invest_widget, "HUNT", INVESTMENT_TYPE.HUNT)
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
end









-- ui manipulations

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


    for i = 1, last_food - 1 do
        if food_cooldown[i] == 0 then
            love.graphics.setColor(1, 0, 0)
        else 
            love.graphics.setColor(0.3, 0, 0)
        end
        c_x = food_pos[i].x * grid_size + grid_size / 2
        c_y = food_pos[i].y * grid_size + grid_size / 2
        love.graphics.circle('line', c_x, c_y, 3)
    end

    love.graphics.setColor(1, 1, 0)
    for i = 1, last_char - 1 do
        if (ALIVE_CHARS[i]) then
            love.graphics.circle('line', chars_x[i], chars_y[i], 2)
        end
    end
    
    love.graphics.setColor(1, 1, 0)
    for i = 1, last_building - 1 do
        love.graphics.rectangle('line', buildings_i[i] * grid_size, buildings_j[i] * grid_size, grid_size, grid_size)
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
        x = x + camera.x;
        y = y + camera.y
        local i, j = coordinates_to_build_grid(x, y);

        if PRESSED_ON_MAP then
            love.graphics.setColor(0, 1, 1, 1)
        else 
            love.graphics.setColor(1, 1, 1, 0.2)
        end

        if ZONE_SELECTION then

            love.graphics.rectangle('line', i * grid_size, j * grid_size, grid_size, grid_size)

            if PRESSED_ON_MAP then
                love.graphics.setColor(0, 1, 0, 0.2)
                local k, h = coordinates_to_build_grid(ORIGIN_OF_PRESSING[1], ORIGIN_OF_PRESSING[2])
                love.graphics.rectangle('fill', k * grid_size, h * grid_size, (i - k) * grid_size, (j - h) * grid_size)
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
        local i, j = coordinates_to_build_grid(x, y);
        local k, h = coordinates_to_build_grid(ORIGIN_OF_PRESSING[1], ORIGIN_OF_PRESSING[2])
        new_zone(nil, k, h, i, j)
    end
    PRESSED_ON_MAP = false
end







-- game logic loop
time_passed = 0
tps = 20
tick = 1 / tps / 10--/ 50

function love.update(dt)
    time_passed = time_passed + dt
    while time_passed > tick do
        time_passed = time_passed - tick
        
        -- chars update
        for i, h in ipairs(chars_hunger) do
            chars_hunger[i] = h + 1
        end
        
        for i, h in ipairs(chars_cooldown) do
            if h > 0 then
                chars_cooldown[i] = h - 1
            end
        end
        
        
        for i = 1, last_char - 1 do
            if ALIVE_CHARS[i] then
                local dice = math.random()
                if dice < CHANCE_FOR_A_POTION_TO_SPOIL then
                    if chars_potions[i] > 0 then
                        chars_potions[i] = chars_potions[i] - 1
                    end
                end
                AGENT_LOGIC[chars_occupation[i]](i)
            end
        end
		
		for i = 1, last_char - 1 do
			if ALIVE_CHARS[i] and (chars_state[i] == CHAR_STATE.HUNTER_GET_SLEEP) then
				if dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
					char_sleep(i)
				end
			end
		end
        
        for i = 1, last_building - 1 do
            if buildings_type[i] == BUILDING_TYPES.RAT_LAIR then
                if buildings_char_amount[i] < 100 then
                    local dice = math.random()
                    if dice > 0.999 then
                        new_rat(i)
                        buildings_char_amount[i] = buildings_char_amount[i] + 1
                    end
                end
            end
        end
        
        for i = 1, last_food - 1 do
            if food_cooldown[i] > 0 then
                food_cooldown[i] = food_cooldown[i] - 1
            end
        end
    end
    
    -- interface update
    wealth_widget:update_label(tostring(kingdom_wealth))
    hunt_widget:update_label(tostring(hunt_budget))
    
    hunt_invest_value:update_label(tostring(BUDGET_RATIO[INVESTMENT_TYPE.HUNT]) .. '%')
    treasury_invest_value:update_label(tostring(BUDGET_RATIO[INVESTMENT_TYPE.TREASURY]) .. '%')
    inc_tax_value:update_label(tostring(INCOME_TAX) .. '%')
end









-- data initialization
function init_chars_arrays()
    last_char = 1
    chars_hp = {}
    chars_weapon = {}
    chars_weapon_d = {}
    chars_armour = {}
    chars_armour_d = {}
    chars_x = {}
    chars_y = {}
    chars_state = {}
    chars_target = {}
    chars_state_target = {}
    chars_wealth = {}
    chars_potions = {}
    chars_home = {}
    chars_occupation = {}
    chars_cooldown = {}
    chars_hunger = {}
	chars_tiredness = {}
end

function init_food_array()
    last_food = 1
    food_pos = {}
    food_cooldown = {}
end

last_state_id = 0
function new_state_id()
    last_state_id = last_state_id + 1
    return last_state_id
end














-- getters
function char_dist(i, j)
    return dist(chars_x[i], chars_y[i], chars_x[j], chars_y[j])
end
function char_build_dist(i, j)
    return dist(chars_x[i], chars_y[i], buildings_x(j), buildings_y(j))
end
function dist(a, b, c, d)
    local t1 = math.abs(a - c)
    local t2 = math.abs(b - d)
    return math.max(t1, t2) + t1 + t2
end

function coordinates_to_build_grid(x, y)
    return math.floor(x / grid_size), math.floor(y / grid_size)
end

function build_grid_to_coordinates(i, j)
    return i * grid_size, j * grid_size
end

function buildings_x(i) 
    return buildings_i[i] * grid_size + grid_size/2
end
function buildings_y(i)
    return buildings_j[i] * grid_size + grid_size/2
end

D_list = {}
D_list[1] = {0, 1}
D_list[2] = {0, -1}
D_list[3] = {1, 1}
D_list[4] = {1, -1}
D_list[5] = {-1, 1}
D_list[6] = {-1, -1}
D_list[7] = {1, 0}
D_list[8] = {-1, 0}

function get_new_building_location()
    local r = 2
    local c_x = buildings_i[1]
    local c_y = buildings_j[1]
    while r < 10 do
        for _, i in ipairs(D_list) do
            local t_x = i[1] * r + c_x
            local t_y = i[2] * r + c_y
            if (map_build_flag[t_x] == nil) or (map_build_flag[t_x][t_y] == nil) then
                local dice = math.random()
                if dice > 0.7 then
                    return t_x, t_y
                end
            end
        end
    end
end

function find_closest_food_shop(i)
    local closest = nil
    local opt_dist = 0
    local x = chars_x[i]
    local y = chars_y[i]
    for j = 1, last_building - 1 do
        local p_x = buildings_x(j)
        local p_y = buildings_y(j)
        local dist = dist(x, y, p_x, p_y)
        if ((closest == nil) or (opt_dist > dist)) and (buildings_type[j] == BUILDING_TYPES.FOOD_SHOP) and (buildings_stash[j] > 0) then
            closest = j
            opt_dist = dist 
        end
    end
    return closest
end

function find_closest_potion_shop(i)
    local closest = nil
    local opt_dist = 0
    local x = chars_x[i]
    local y = chars_y[i]
    for j = 1, last_building - 1 do
        local p_x = buildings_x(j)
        local p_y = buildings_y(j)
        local dist = dist(x, y, p_x, p_y)
        if ((closest == nil) or (opt_dist > dist)) and (buildings_type[j] == BUILDING_TYPES.ALCHEMIST) and (buildings_stash[j] > 0) then
            closest = j
            opt_dist = dist 
        end
    end
    return closest
end


-- constructors
function new_char(hp, wealth, state, home) 
    chars_hp[last_char] = hp
    chars_wealth[last_char] = wealth
    chars_weapon[last_char] = 3
    chars_armour[last_char] = 1
    chars_state[last_char] = state 
    chars_target[last_char] = {}
    chars_state_target[last_char] = nil
    chars_home[last_char] = home
    chars_x[last_char] = buildings_i[chars_home[last_char]] * grid_size + grid_size/2
    chars_y[last_char] = buildings_j[chars_home[last_char]] * grid_size + grid_size/2
    chars_occupation[last_char] = CHAR_OCCUPATION.HUNTER
    chars_potions[last_char] = 0
    chars_cooldown[last_char] = 0
    ALIVE_CHARS[last_char] = true
    chars_hunger[last_char] = 0
	chars_tiredness[last_char] = 0
    last_char = last_char + 1
end

function new_food(x, y)
    food_pos[last_food] = {}
    food_pos[last_food].x = x
    food_pos[last_food].y = y
    food_cooldown[last_food] = 0
    last_food = last_food + 1
end

function new_tax_collector()
    new_char(50, 0, CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE, 1)
    chars_occupation[last_char - 1] = CHAR_OCCUPATION.TAX_COLLECTOR
end

function new_hero(wealth)
    ALIVE_HEROES[last_char] = true
    new_char(100, wealth, CHAR_STATE.WANDERING, 1)
    chars_weapon[last_char - 1] = 2
    return last_char - 1
end

function new_rat(nest)
    chars_hp[last_char] = 30
    chars_wealth[last_char] = 0
    chars_weapon[last_char] = 2
    chars_weapon_d[last_char] = 100
    chars_armour[last_char] = 1
    chars_armour_d[last_char] = 100
    chars_state[last_char] = CHAR_STATE.PROTECT_THE_LAIR
    chars_target[last_char] = {}
    chars_home[last_char] = nest
    chars_potions[last_char] = 0
    chars_x[last_char] = buildings_i[chars_home[last_char]] * grid_size + grid_size/2
    chars_y[last_char] = buildings_j[chars_home[last_char]] * grid_size + grid_size/2
    chars_occupation[last_char] = CHAR_OCCUPATION.RAT
    ALIVE_RATS[last_char] = true
    ALIVE_CHARS[last_char] = true
    chars_hunger[last_char] = 0
	chars_tiredness[last_char] = 0
    last_char = last_char + 1
end



function new_building(buiding_type, i, j)
    if map_build_flag[i] == nil then
        map_build_flag[i] = {}
    end
    map_build_flag[i][j] = true
    
    buildings_i[last_building] = i
    buildings_j[last_building] = j
    buildings_type[last_building] = buiding_type
    buildings_wealth_before_taxes[last_building] = 0
    buildings_wealth_after_taxes[last_building] = 0
    buildings_char_amount[last_building] = 0
    buildings_stash[last_building] = 0
    building_is_state_owned[last_building] = false
    last_building = last_building + 1
    return last_building - 1
end


















-- character manipulation functions
MOVEMENT_RESPONCES = {}
MOVEMENT_RESPONCES.TARGET_REACHED = 1
MOVEMENT_RESPONCES.STILL_MOVING = 2
function char_move_to_target(i)
    if chars_target[i].x == nil then
        return
    end
    local dx = chars_target[i].x - chars_x[i]
    local dy = chars_target[i].y - chars_y[i]
    local norm = math.sqrt(dx * dx + dy * dy)
    if (norm > 1) then
        chars_x[i] = chars_x[i] + dx / norm
        chars_y[i] = chars_y[i] + dy / norm
        return MOVEMENT_RESPONCES.STILL_MOVING
    else
        chars_x[i] = chars_x[i] + dx 
        chars_y[i] = chars_y[i] + dy
        return MOVEMENT_RESPONCES.TARGET_REACHED
    end
end

function char_buy_potions(i, shop)
    if chars_wealth[i] >= POTION_PRICE then
        buildings_wealth_before_taxes[shop] = buildings_wealth_before_taxes[shop] + POTION_PRICE
        chars_wealth[i] = chars_wealth[i] - POTION_PRICE
        chars_potions[i] = chars_potions[i] + 1
    end
end

function char_buy_food(i, shop)
    if chars_wealth[i] >= FOOD_PRICE then
        buildings_wealth_before_taxes[shop] = buildings_wealth_before_taxes[shop] + FOOD_PRICE
        chars_wealth[i] = chars_wealth[i] - FOOD_PRICE
        buildings_stash[shop] = buildings_stash[shop] - 1
        char_change_hp(i, 10)
        chars_hunger[i] = 0
    end
end

function char_sleep(i)
	print(chars_tiredness[i])
	chars_tiredness[i] = math.max(chars_tiredness[i] - 1, 0)
end

function char_tax_building(i, shop)
    local tax = 0
    if building_is_state_owned[i] then
        tax = buildings_wealth_before_taxes[shop]
    else
        tax = math.floor(buildings_wealth_before_taxes[shop] * INCOME_TAX / 100)
    end
    chars_wealth[i] = chars_wealth[i] + tax
    buildings_wealth_after_taxes[shop] = buildings_wealth_before_taxes[shop] - tax
    buildings_wealth_before_taxes[shop] = 0
end

function char_return_tax(i)
    kingdom_income(chars_wealth[i])
    chars_wealth[i] = 0
end

function char_attack_char(i, j)
	print(chars_tiredness[i])
	chars_tiredness[i] = chars_tiredness[i] + 1
    if chars_weapon[i] > chars_armour[j] then
        local tmp = char_change_hp(j, -10 + chars_armour[j] - chars_weapon[i])
        if tmp == CHANGE_HP_RESPONSE.DEAD then
            chars_wealth[i] = chars_wealth[i] + chars_wealth[j]
            chars_wealth[j] = 0
            return CHAR_ATTACK_RESPONSE.KILL
        end
        return CHAR_ATTACK_RESPONSE.DAMAGE
    end
    return CHAR_ATTACK_RESPONSE.NO_DAMAGE
end

function char_drink_pot(i)
    if chars_potions[i] > 0 then 
        chars_potions[i] = chars_potions[i] - 1
        char_change_hp(i, 30)
    end
end

function char_change_hp(i, dh)
    if chars_hp[i] + dh > 0 then
        chars_hp[i] = chars_hp[i] + dh
        return CHANGE_HP_RESPONSE.ALIVE
    else 
        ALIVE_HEROES[i] = nil
        ALIVE_RATS[i] = nil
        ALIVE_CHARS[i] = nil
        return CHANGE_HP_RESPONSE.DEAD
    end
end

function char_recieve_reward(i)
    if hunt_budget > REWARD then
        chars_wealth[i] = chars_wealth[i] + REWARD
        hunt_budget = hunt_budget - REWARD
    else
        chars_wealth[i] = chars_wealth[i] + hunt_budget
        hunt_budget = 0
    end
end

function char_change_state(i, state)
    if (state == nil) then
        error("character state changed to nil")
    end
    if (chars_state[i] == state) then
        return
    end
    chars_state[i] = state
    chars_target[i].x = nil
    chars_target[i].y = nil
    chars_state_target[i] = nil
end

function char_set_home(a, b)
    chars_home[a] = b
end

function char_collect_food(i, j)
    food_cooldown[j] = 10000
end

function char_transfer_item_building(i, j)
    buildings_stash[j] = buildings_stash[j] + 1
end

function char_collect_money_from_building(i, j)
    local tmp = buildings_wealth_after_taxes[j]
    buildings_wealth_after_taxes[j] = 0
    chars_wealth[i] = chars_wealth[i] + tmp
end








-- actions of a king
function hire_hero()
    if kingdom_wealth >= 100 then
        kingdom_wealth = kingdom_wealth - 100
        new_hero(100)
    end
end
function add_hunt_budget()
    if kingdom_wealth >= 100 then
        kingdom_wealth = kingdom_wealth - 100
        hunt_budget = hunt_budget + 100
    else 
        hunt_budget = hunt_budget + kingdom_wealth
        kingdom_wealth = 0
    end
end
function dec_inv(it)
    if BUDGET_RATIO[it] > 0 then
        BUDGET_RATIO[it] = BUDGET_RATIO[it] - 10
        BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] = BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] + 10
    end
end
function inc_inv(it)
    if BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] > 0 then
        BUDGET_RATIO[it] = BUDGET_RATIO[it] + 10
        BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] = BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] - 10
    end
end

function dec_tax(it)
    if INCOME_TAX > 0 then
        INCOME_TAX = INCOME_TAX - 10
    end
end
function inc_tax(it)
    if INCOME_TAX < 100 then
        INCOME_TAX = INCOME_TAX + 10
    end
end


-- zones
ZONE_TYPE = {}
ZONE_TYPE.ATTACK = 1
ZONES = {}


function new_zone(z_type, x1, y1, x2, y2)
    zone = {}
    zone.type = z_type
    zone.x1 = x1
    zone.x2 = x2
    zone.y1 = y1
    zone.y2 = y2
    table.insert(ZONES, zone)
end

function delete_zone(i)
    table.remove(ZONES, i)
end

function is_in_zone(type, x, y)
    for i, zone in pairs(ZONES) do
        if (x < zone.x1) and (zone.x1 < x) and (y < zone.y2) and (zone.y1 < y) then
            return true
        end
    end
    return false
end


-- kingdom manipulatino
function kingdom_income(t)
    local tmp = math.floor(BUDGET_RATIO[INVESTMENT_TYPE.HUNT] * t / 100)
    kingdom_wealth = kingdom_wealth + t - tmp
    hunt_budget = hunt_budget + tmp
end







function init_occupation_vars()
	-- occupation list
	CHAR_OCCUPATION = {}
	CHAR_OCCUPATION.TAX_COLLECTOR = 1 -- character that collects taxes in buildings and returns them to castle
	CHAR_OCCUPATION.HUNTER = 2 -- character that, if there is a hunting reward, hunts on corresponding targets
	CHAR_OCCUPATION.GUARD = 3 -- character that guards his home
	CHAR_OCCUPATION.RAT = 4
	CHAR_OCCUPATION.FOOD_COLLECTOR = 5

	-- occupation logic
	AGENT_LOGIC = {}
	STATE_LOGIC = {}


	init_tax_collector()
	init_hunter()
	init_rat()
	init_food_collector()


	-- HERBALIST
	---- herbalist 
	---- collects plants around, 
	---- brews potions out of them for sell (ensuring that he always have enough for himself)
	---- potions can expire, so his goods are always needed
	---- buys herbs from other heroes
	---- income: selling potions
	---- expenses: buying plants, buying food, taxes 

end