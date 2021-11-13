local milky = require "milky"
milky.render_rectangles = false

function love.load()
    love.window.setMode(800, 600, flags )
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
    
    INCOME_TAX = 0

    
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
    
    BUILDING_TYPES = {}
    BUILDING_TYPES.ALCHEMIST = 0   
    BUILDING_TYPES.CASTLE = 1
    BUILDING_TYPES.RAT_LAIR = 2
    BUILDING_TYPES.FOOD_SHOP = 3
    
    
    -- game data
    
    kingdom_wealth = 500
    
    new_building(BUILDING_TYPES.CASTLE, 30, 30)
    new_building(BUILDING_TYPES.ALCHEMIST, 37, 23)
    
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
        rewards_label_rat_value = milky.panel:new(milky, rewards_widget, '10'):position(120, 35)
    
    
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
        
        hire_button_label = milky.panel:new(milky, hire_button, "HIRE A HERO (100)"):position(5, 2)
    
    
    add_hunt_budget_button = milky.panel:new(milky, main_ui)
        :position(3, 527)
        :size(192, 24)
        :button(milky, function (self, button) add_hunt_budget() end)
        :toogle_border()
        
        add_hunt_budget_label = milky.panel:new(milky, add_hunt_budget_button, "ADD HUNT MONEY (100)"):position(5, 2)
end









-- ui manipulations

function create_invest_row(parent, label, it)
    local body = milky.panel:new(milky, parent):size(187, 25):position(0, 0)
    
    local label = milky.panel:new(milky, body, label):position(0, 5):size(80, 17)
    local value = milky.panel:new(milky, body, '???'):position(120, 5):size(35, 17)
    local bd = milky.panel:new(milky, body, " -"):position(90, 5):size(15, 15):button(milky, function (self, button) dec_inv(it) end):toogle_border()
    local bi = milky.panel:new(milky, body, " +"):position(160, 5):size(15, 15):button(milky, function (self, button) inc_inv(it) end):toogle_border()
    
    return body, value
end











-- draw loop
function love.draw()    
    love.graphics.setColor(1, 1, 0)
    for i = 1, last_char - 1 do
        if (ALIVE_CHARS[i]) then
            love.graphics.circle('line', chars_x[i], chars_y[i], 2)
        end
    end
    
    for i = 1, last_building - 1 do
        love.graphics.rectangle('line', buildings_i[i] * grid_size, buildings_j[i] * grid_size, grid_size, grid_size)
    end
    
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
    main_ui:draw()
    
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
        
        for i = 1, last_building - 1 do
            if buildings_type[i] == BUILDING_TYPES.RAT_LAIR then
                if buildings_char_amount[i] < 100 then
                    local dice = math.random()
                    if dice > 0.995 then
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

function love.mousepressed(x, y, button, istouch)
    milky:onClick(x, y, button)
end
function love.mousereleased(x, y, button, istouch)
    milky:onRelease(x, y, button)
end
function love.mousemoved(x, y, dx, dy, istouch)
    milky:onHover(x, y)
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
                dice = math.random()
                if dice > 0.7 then
                    return t_x, t_y
                end
            end
        end
    end
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

function char_tax_building(i, shop)
    chars_wealth[i] = chars_wealth[i] + buildings_wealth_before_taxes[shop]
    buildings_wealth_before_taxes[shop] = 0
end

function char_return_tax(i)
    kingdom_income(chars_wealth[i])
    chars_wealth[i] = 0
end

function char_attack_char(i, j)
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




-- TAX COLLECTOR

-- TAX COLLECTOR SETTINGS
MIN_GOLD_TO_TAX = 9
MAX_GOLD_TO_CARRY = 100

-- TAX_COLLECTOR STATES
CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES = new_state_id()
CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES = new_state_id()
CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE = new_state_id()

-- TAX COLLECTOR RESPONCES
TAX_COLLECTOR_RESPONCES = {}
TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS = 1
TAX_COLLECTOR_RESPONCES.FOUND_TARGET = 2
TAX_COLLECTOR_RESPONCES.ON_MY_WAY = 3
TAX_COLLECTOR_RESPONCES.IN_CASTLE = 4
TAX_COLLECTOR_RESPONCES.GOT_TAX = 5
TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED = 6

AGENT_LOGIC[CHAR_OCCUPATION.TAX_COLLECTOR] = function (i)
    

    if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES then
        res = TAX_COLLECTOR_COLLECT_TAXES(i)
        
        if res == TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED then
            char_change_state(i, CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES)
        end
        if res == TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS then
            char_change_state(i, CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES)
        end
        if res == TAX_COLLECTOR_RESPONCES.FOUND_TARGET then
            -- ok
        end
        if res == TAX_COLLECTOR_RESPONCES.GOT_TAX then
            -- ok
        end
        if res == TAX_COLLECTOR_RESPONCES.ON_MY_WAY then
            -- ok
        end
    end
    
    if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_RETURN_TAXES then
        res = TAX_COLLECTOR_RETURN_TAXES(i)
        if res == TAX_COLLECTOR_RESPONCES.IN_CASTLE then
            char_change_state(i, CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE)
        end
    end
    
    if chars_state[i] == CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE then
        res = TAX_COLLECTOR_WAIT_IN_CASTLE(i)
        if res == TAX_COLLECTOR_RESPONCES.FOUND_TARGET then
            char_change_state(i, CHAR_STATE.TAX_COLLECTOR_COLLECT_TAXES)
        end
    end
    
end

function TAX_COLLECTOR_COLLECT_TAXES(i)
    if chars_wealth[i] > MAX_GOLD_TO_CARRY then
        return TAX_COLLECTOR_RESPONCES.MAX_GOLD_REACHED
    end
    
    if chars_state_target[i] == nil then
        -- if no target, then find the most optimal (wealth to tax / distance) building and set it as a target
        local optimal = 0
        local final_target = nil
        
        for j, w in ipairs(buildings_wealth_before_taxes) do
            if (w > MIN_GOLD_TO_TAX) and (w / char_build_dist(i, j) > optimal) then
                optimal = w / char_build_dist(i, j)
                final_target = j
            end
        end
        
        if final_target == nil then
            return TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS
        end
        
        chars_state_target[i] = final_target
        chars_target[i].x = buildings_x(final_target)
        chars_target[i].y = buildings_y(final_target)
        return TAX_COLLECTOR_RESPONCES.FOUND_TARGET
    elseif chars_state_target[i] ~= nil then
        if char_build_dist(i, chars_state_target[i]) < 0.5 then
            char_tax_building(i, chars_state_target[i])
            chars_state_target[i] = nil
            return TAX_COLLECTOR_RESPONCES.GOT_TAX
        else 
            char_move_to_target(i)
            return TAX_COLLECTOR_RESPONCES.ON_MY_WAY
        end
    end
end

function TAX_COLLECTOR_RETURN_TAXES(i)
    if chars_state_target[i] == nil then
        local closest_tax_storage = 1
        chars_state_target[i] = 1
        chars_target[i].x = buildings_x(closest_tax_storage)
        chars_target[i].y = buildings_y(closest_tax_storage)
    elseif chars_state_target[i] ~= nil then
        if dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
            char_return_tax(i)
            chars_state_target[i] = nil
            return TAX_COLLECTOR_RESPONCES.IN_CASTLE
        else 
            char_move_to_target(i)
            return TAX_COLLECTOR_RESPONCES.ON_MY_WAY
        end
    end
end

function TAX_COLLECTOR_WAIT_IN_CASTLE(i)
    local optimal, final_target = FIND_OPTIMAL_BUILDING_TO_TAX(i)
    
    if final_target == nil then
        return TAX_COLLECTOR_RESPONCES.NO_TAXABLE_BUILDINGS
    end
    
    chars_state_target[i] = final_target
    chars_target[i].x = buildings_x(final_target)
    chars_target[i].y = buildings_y(final_target)
    
    return TAX_COLLECTOR_RESPONCES.FOUND_TARGET
end

function FIND_OPTIMAL_BUILDING_TO_TAX(i)
    local optimal = 0
    local final_target = nil
    
    for j, w in ipairs(buildings_wealth_before_taxes) do
        if (w > MIN_GOLD_TO_TAX) and (w / char_build_dist(i, j) > optimal) then
            optimal = w / char_build_dist(i, j)
            final_target = j
        end
    end
    return optimal, final_target
end


-- HUNTER
-- HUNTER SETTINGS
HUNTER_DESIRED_AMOUNT_OF_POTIONS = 5
HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION = -2
HUNTER_DESITE_TO_HUNT_FOR_REWARD = 3
HUNTER_DESITE_TO_HUNT_WITHOUT_REWARD = -3
HUNTER_DESIRE_TO_CONTINUE_HUNT = 1
HUNTER_NO_RATS_HUNT_COOLDOWN = 100

-- HUNTER STATES
CHAR_STATE.HUNTER_BUY_POTION = new_state_id()
CHAR_STATE.HUNTER_BUY_FOOD = new_state_id()
CHAR_STATE.HUNTER_HUNT = new_state_id()
CHAR_STATE.HUNTER_WANDER = new_state_id()

-- HUNTER RESPONCES
HUNTER_RESPONCES = {}
HUNTER_RESPONCES.ON_MY_WAY = 1
HUNTER_RESPONCES.FOUND_TARGET = 2
HUNTER_RESPONCES.BOUGHT_POTION = 3
HUNTER_RESPONCES.TARGET_REACHED = 4
HUNTER_RESPONCES.NO_RATS = 5
HUNTER_RESPONCES.BOUGHT_FOOD = 6

--HUNTER DESIRES
HUNTER_DESIRE = {}
HUNTER_DESIRE.POTION = 1
HUNTER_DESIRE.FOOD = 2
HUNTER_DESIRE.HUNT = 3

DESIRE_CALC = {}
DESIRE_CALC[HUNTER_DESIRE.POTION] = function(i)
    if (chars_wealth[i] < POTION_PRICE) then
        return 0
    end
    return -(HUNTER_DESIRED_AMOUNT_OF_POTIONS - chars_potions[i]) * HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION
end

DESIRE_CALC[HUNTER_DESIRE.FOOD] = function(i)
    if (chars_wealth[i] < FOOD_PRICE) then
        return 0
    end
    return chars_hunger[i] / 1000
end

DESIRE_CALC[HUNTER_DESIRE.HUNT] = function(i)
    local hunting_desire = HUNTER_DESITE_TO_HUNT_FOR_REWARD
    if (REWARD < hunt_budget) then
        return hunting_desire
    end

    hunting_desire = hunting_desire + HUNTER_DESITE_TO_HUNT_FOR_REWARD
        
    if chars_cooldown[i] > 0 then
        hunting_desire = hunting_desire - 1000
    end
    
    if chars_wealth[i] < 2 * POTION_PRICE then
        hunting_desire = hunting_desire + HUNTER_DESITE_TO_HUNT_FOR_REWARD * 2
    end
    
    if chars_state[i] == CHAR_STATE.HUNTER_HUNT then
        hunting_desire = hunting_desire + HUNTER_DESIRE_TO_CONTINUE_HUNT
    end
    
    return hunting_desire
end

AGENT_LOGIC[CHAR_OCCUPATION.HUNTER] = function (i)
    if chars_hp[i] < 60 then
        char_drink_pot(i)
    end
    
    if chars_cooldown[i] > 0 then
        chars_cooldown[i] = chars_cooldown[i] - 1
    end
    
    if chars_state[i] == nil then
        char_change_state(i, CHAR_STATE.HUNTER_WANDER)
    end
    
    
    
    local desire = {}    
    desire[HUNTER_DESIRE.POTION] = DESIRE_CALC[HUNTER_DESIRE.POTION](i)
    desire[HUNTER_DESIRE.FOOD] = DESIRE_CALC[HUNTER_DESIRE.FOOD](i)
    desire[HUNTER_DESIRE.HUNT] = DESIRE_CALC[HUNTER_DESIRE.HUNT](i)
    
    local max_desire = 0
    for i = 1, 3 do
        if (max_desire == 0) or (desire[max_desire] < desire[i]) then
            max_desire = i
        end
    end
    
    if max_desire == HUNTER_DESIRE.POTION then
        char_change_state(i, CHAR_STATE.HUNTER_BUY_POTION)
    elseif max_desire == HUNTER_DESIRE.FOOD then
        char_change_state(i, CHAR_STATE.HUNTER_BUY_FOOD)
    elseif max_desire == HUNTER_DESIRE.HUNT then
        char_change_state(i, CHAR_STATE.HUNTER_HUNT)
    else
        char_change_state(i, CHAR_STATE.HUNTER_WANDER)
    end
    
    
    
    if chars_state[i] == CHAR_STATE.HUNTER_HUNT then
        res = HUNTER_HUNT(i)
        if res == HUNTER_RESPONCES.NO_RATS then
            chars_cooldown[i] = HUNTER_NO_RATS_HUNT_COOLDOWN
            char_change_state(i, CHAR_STATE.HUNTER_WANDER)
        end
    end
    if chars_state[i] == CHAR_STATE.HUNTER_WANDER then
        res = HUNTER_WANDER(i)
        if res == HUNTER_RESPONCES.TARGET_REACHED then
            chars_state_target[i] = nil
        end
    end
    if chars_state[i] == CHAR_STATE.HUNTER_BUY_POTION then
        res = HUNTER_BUY_POTION(i)
        if res == HUNTER_RESPONCES.BOUGHT_POTION then
            char_change_state(i, CHAR_STATE.HUNTER_WANDER)
        end
    end
    
    if chars_state[i] == CHAR_STATE.HUNTER_BUY_FOOD then
        res = HUNTER_BUY_FOOD(i)
        if res == HUNTER_RESPONCES.BOUGHT_FOOD then
            char_change_state(i, CHAR_STATE.HUNTER_WANDER)
        end
    end
end

function HUNTER_HUNT(i)
    local closest_rat = nil
    local curr_dist = 99999
    for j, f in pairs(ALIVE_RATS) do
        if f then
            local tmp = char_dist(j, i)
            if (closest_rat == nil) or (tmp < curr_dist) then
                closest_rat = j
                curr_dist = tmp
            end
        end
    end
    if closest_rat ~= nil then
        chars_target[i].x = chars_x[closest_rat]
        chars_target[i].y = chars_y[closest_rat]
        chars_state_target[i] = closest_rat
        
        if curr_dist > 1 then 
            char_move_to_target(i)
        else
            local tmp = char_attack_char(i, closest_rat)
            if (tmp == CHAR_ATTACK_RESPONSE.KILL) then
                char_recieve_reward(i)
            end
        end
        
        chars_state_target[i] = nil
    end
    
    if (chars_state_target[i] == nil) and (closest_rat == nil) then
        return HUNTER_RESPONCES.NO_RATS
    end
end

function HUNTER_WANDER(i)
    if chars_state_target[i] == nil then
        chars_state_target[i] = -1
        local dice = math.random() - 0.5
        chars_target[i].x = dice * dice * dice * 400 + buildings_x(chars_home[i])
        local dice = math.random() - 0.5
        chars_target[i].y = dice * dice * dice * 400 + buildings_y(chars_home[i])
    elseif chars_target[i] ~= nil then
        local res = char_move_to_target(i)
        if res == MOVEMENT_RESPONCES.STILL_MOVING then
            return HUNTER_RESPONCES.ON_MY_WAY
        end
        if res == MOVEMENT_RESPONCES.TARGET_REACHED then
            return HUNTER_RESPONCES.TARGET_REACHED
        end
    end
end

function HUNTER_BUY_POTION(i)
    if chars_state_target[i] == nil then
        local closest_shop = 2 -- should rewrite to finding the closest shop
        chars_state_target[i] = closest_shop
        chars_target[i].x = buildings_x(closest_shop)
        chars_target[i].y = buildings_y(closest_shop)
        
    elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
        local closest_shop = 2 -- should rewrite to finding the closest shop
        char_buy_potions(i, closest_shop)
        return HUNTER_RESPONCES.BOUGHT_POTION
    else 
        char_move_to_target(i)
        return HUNTER_RESPONCES.ON_MY_WAY
    end
end

function HUNTER_BUY_FOOD(i)
    if chars_state_target[i] == nil then
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
        if closest ~= nil then
            chars_state_target[i] = closest
            chars_target[i].x = buildings_x(closest)
            chars_target[i].y = buildings_y(closest)
        end
    elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then

        char_buy_food(i, chars_state_target[i])
        return HUNTER_RESPONCES.BOUGHT_FOOD
    else 
        char_move_to_target(i)
        return HUNTER_RESPONCES.ON_MY_WAY
    end
end


-- RAT
---- rats are common vermin that hurts your early stage of the kingdom 


-- RAT SETTINGS
RAT_DISTANCE_FROM_LAIR = 410

-- RAT STATES
CHAR_STATE.RAT_PROTECT_LAIR = new_state_id()

-- HUNTER RESPONCES
RAT_RESPONCES = {}
RAT_RESPONCES.ON_MY_WAY = 1
RAT_RESPONCES.FOUND_TARGET = 2
RAT_RESPONCES.TARGET_REACHED = 3
RAT_RESPONCES.NO_ENEMIES = 4

AGENT_LOGIC[CHAR_OCCUPATION.RAT] = function (i)
    RAT_PROTECT_LAIR(i)
end

function RAT_PROTECT_LAIR(i)
    local closest_hero = nil
    local curr_dist = 20
    for j, f in pairs(ALIVE_HEROES) do
        if f then
            local tmp = char_dist(j, i)
            if ((closest_hero == nil) and (tmp < curr_dist)) or (tmp < curr_dist) then
                closest_hero = j
                curr_dist = tmp
            end
        end
    end
    local from_home_dist = char_build_dist(i, chars_home[i])
    if (closest_hero ~= nil) and (from_home_dist < RAT_DISTANCE_FROM_LAIR) then
        chars_target[i] = {}
        chars_target[i].x = chars_x[closest_hero]
        chars_target[i].y = chars_y[closest_hero]
        if curr_dist > 1 then 
            char_move_to_target(i)
        else
            char_attack_char(i, closest_hero)
        end
    elseif chars_target[i].x == nil then
        local dice = math.random() - 0.5
        chars_target[i].x = dice * dice * dice * 800 + buildings_x(chars_home[i])
        local dice = math.random() - 0.5
        chars_target[i].y = dice * dice * dice * 800 + buildings_y(chars_home[i])
    elseif chars_target[i].x ~= nil then
        res = char_move_to_target(i)
        if res == MOVEMENT_RESPONCES.TARGET_REACHED then
            chars_target[i].x = nil
            chars_target[i].y = nil
        end
    end
end


-- FOOD_COLLECTOR
---- food collector is an agent that goes to food that randomly grows around the map,  +
---- collects it and sells it in his shop, which he sets up not far from the castle +
---- during collection, he could hurt himself, so he is carrying a bit of potions with him -
---- he can carry only one food item in hands +
---- one food item restores full hp and removes hunger but can't be carried like a potion
---- so other agents should prioritise eating to using potions, if they are not engaged in other activities 
---- income: selling food 
---- expenses: potions, taxes
FOOD_COLLECTOR_FOOD_TO_REMAIN_AT_HOME = 10

CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP = new_state_id()
CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD = new_state_id()
CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD = new_state_id()
CHAR_STATE.FOOD_COLLECTOR_SELL_FOOD = new_state_id()

FOOD_COLLECTOR_RESPONCES = {}
FOOD_COLLECTOR_RESPONCES.GOT_FOOD = 1
FOOD_COLLECTOR_RESPONCES.AT_HOME = 2
FOOD_COLLECTOR_RESPONCES.NO_FOOD_AROUND = 3
FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT = 4
AGENT_LOGIC[CHAR_OCCUPATION.FOOD_COLLECTOR] = function (i)
    if chars_state[i] == nil then
        chars_state[i] = CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP
    end
    
    
    if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_SET_UP_SHOP then
        local x, y = get_new_building_location()
        local bid = new_building(BUILDING_TYPES.FOOD_SHOP, x, y)
        char_set_home(i, bid)
        char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
    end
    
    if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD then
        local res = FOOD_COLLECTOR_COLLECT_FOOD(i)
        if res == FOOD_COLLECTOR_RESPONCES.GOT_FOOD then
            char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD)
        end
    end
    
    if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_RETURN_FOOD then
        local res = FOOD_COLLECTOR_RETURN_FOOD(i)
        if res == FOOD_COLLECTOR_RESPONCES.AT_HOME then
            local home = chars_home[i]
            if buildings_stash[home] >= FOOD_COLLECTOR_FOOD_TO_REMAIN_AT_HOME then
                char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_SELL_FOOD)
            else
                char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
            end
        end
    end
    
    if chars_state[i] == CHAR_STATE.FOOD_COLLECTOR_SELL_FOOD then
        local res = FOOD_COLLECTOR_STAY_IN_SHOP(i)
        if res == FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT then
            char_change_state(i, CHAR_STATE.FOOD_COLLECTOR_COLLECT_FOOD)
        end
    end
end

function FOOD_COLLECTOR_COLLECT_FOOD(i)
    if chars_state_target[i] == nil then
        local optimal_dist = 0
        local optimal_food = nil
        local x = chars_x[i]
        local y = chars_y[i]
        for f, pos in ipairs(food_pos) do
            local p_x = pos.x * grid_size + grid_size/2
            local p_y = pos.y * grid_size + grid_size/2
            local dist = dist(x, y, p_x, p_y)
            if ((optimal_food == nil) or (optimal_dist > dist)) and (food_cooldown[f] == 0) then
                optimal_food = f
                optimal_dist = dist                
            end
        end
        
        if optimal_food == nil then
            return FOOD_COLLECTOR_RESPONCES.NO_FOOD_AROUND
        end
        
        chars_state_target[i] = optimal_food
        chars_target[i].x = food_pos[optimal_food].x * grid_size + grid_size/2
        chars_target[i].y = food_pos[optimal_food].y * grid_size + grid_size/2
    else 
        local res = char_move_to_target(i)
        if res == MOVEMENT_RESPONCES.TARGET_REACHED then
            char_collect_food(i, chars_state_target[i])
            return FOOD_COLLECTOR_RESPONCES.GOT_FOOD
        end
    end
end

function FOOD_COLLECTOR_RETURN_FOOD(i)
    if chars_state_target[i] == nil then
        chars_state_target[i] = chars_home[i]
        chars_target[i].x = buildings_x(chars_home[i])
        chars_target[i].y = buildings_y(chars_home[i])
    else 
        local res = char_move_to_target(i)
        if res == MOVEMENT_RESPONCES.TARGET_REACHED then
            char_transfer_item_building(i, chars_state_target[i])
            return FOOD_COLLECTOR_RESPONCES.AT_HOME
        end
    end
end

function FOOD_COLLECTOR_STAY_IN_SHOP(i)
    local home = chars_home[i]
    if buildings_stash[home] == 0 then
        return FOOD_COLLECTOR_RESPONCES.NO_FOOD_LEFT
    end
end



-- HERBALIST
---- herbalist 
---- collects plants around, 
---- brews potions out of them for sell (ensuring that he always have enough for himself)
---- potions can expire, so his goods are always needed
---- buys herbs from other heroes
---- income: selling potions
---- expenses: buying plants, buying food, taxes 

end