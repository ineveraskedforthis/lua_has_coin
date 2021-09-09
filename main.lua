local milky = require "milky"
milky.render_rectangles = true

function love.load()
    love.window.setMode(800, 600, flags )
    grid_size = 10

    -- data structs init
    
    -- lists
    
    ALIVE_RATS = {}
    ALIVE_HEROES = {}
    ALIVE_CHARS = {}
    
    -- kingdom 
    kingdom_wealth = 0
    hunt_budget = 0
    
    REWARD = 10
    
    INVESTMENT_TYPE = {}
    INVESTMENT_TYPE.TREASURY = 0
    INVESTMENT_TYPE.HUNT = 1
    
    BUDGET_RATIO = {}
    BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] = 100
    BUDGET_RATIO[INVESTMENT_TYPE.HUNT] = 0

    -- chars
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
    chars_wealth = {}
    chars_potions = {}
    chars_home = {}
    
    CHAR_STATE = {}
    CHAR_STATE.WANDERING = 0
    CHAR_STATE.FIGHT = 1
    CHAR_STATE.TAXCOLLECTION = 2
    CHAR_STATE.RETURNTAXES = 3
    CHAR_STATE.BUY_POTIONS = 4
    CHAR_STATE.HUNT = 5
    CHAR_STATE.PROTECT_THE_LAIR = 6
    
    
    -- responses
    CHANGE_HP_RESPONSE = {}
    CHANGE_HP_RESPONSE.DEAD = 0
    CHANGE_HP_RESPONSE.ALIVE = 1
    
    
    CHAR_ATTACK_RESPONSE = {}
    CHAR_ATTACK_RESPONSE.KILL = 0
    CHAR_ATTACK_RESPONSE.DAMAGE = 1
    CHAR_ATTACK_RESPONSE.NO_DAMAGE = 2
    
    -- buildings
    last_building = 1
    buildings_i = {}
    buildings_j = {}
    buildings_wealth_before_taxes = {}
    buildings_wealth_after_taxes = {}
    buildings_type = {}
    buildings_char_amount = {}
    
    BUILDING_TYPES = {}
    BUILDING_TYPES.ALCHEMIST = 0   
    BUILDING_TYPES.CASTLE = 1
    BUILDING_TYPES.RAT_LAIR = 2
    
    
    -- game data
    
    kingdom_wealth = 500
    
    new_building(BUILDING_TYPES.CASTLE, 30, 30)
    new_building(BUILDING_TYPES.ALCHEMIST, 37, 23)
    
    new_building(BUILDING_TYPES.RAT_LAIR, 7, 8)    
    new_building(BUILDING_TYPES.RAT_LAIR, 3, 50)
    new_building(BUILDING_TYPES.RAT_LAIR, 53, 37)
    
    new_tax_collector()
    
    
    -- interface init
    main_ui = milky.panel:new(milky, nil, nil, nil):position(600,0):size(200, 600)
    
    wealth_label = milky.panel:new(milky, main_ui, 'TREASURY'):position(5, 0)
    wealth_widget = milky.panel:new(milky, main_ui, "???", nil):position(150, 0)
    
    hunt_label = milky.panel:new(milky, main_ui, 'HUNT INVESTED'):position(5, 20)
    hunt_widget = milky.panel:new(milky, main_ui, "???", nil):position(150, 20)
    
    income_invest_label = milky.panel:new(milky, main_ui, 'ROYAL INVESTMENTS'):position(5, 60)
    treasury_invest_body, treasury_invest_value = create_invest_row(main_ui, "TREASURY", INVESTMENT_TYPE.TREASURY)
    hunt_invest_body, hunt_invest_value = create_invest_row(main_ui, "HUNT", INVESTMENT_TYPE.HUNT)
    treasury_invest_body:position(5, 80)
    hunt_invest_body:position(5, 100)
    
    rewards_label = milky.panel:new(milky, main_ui, 'REWARDS'):position(5, 260)
    rewards_label_rat = milky.panel:new(milky, main_ui, 'RAT'):position(5, 280)
    rewards_label_rat_value = milky.panel:new(milky, main_ui, '10'):position(105, 280)
    
    hire_button = milky.panel:new(milky, main_ui, "HIRE A HERO (100)")
    :position(5, 400)
    :size(190, 20)
    :button(milky, function (self, button) hire_hero() end)
    
    add_hunt_budget_button = milky.panel:new(milky, main_ui, "ADD HUNT MONEY (100)")
    :position(5, 430)
    :size(190, 20)
    :button(milky, function (self, button) add_hunt_budget() end)
end

function create_invest_row(parent, label, it)
    local body = milky.panel:new(milky, parent, nil, nil)
    
    local label = milky.panel:new(milky, body, label):position(0, 0)
    local value = milky.panel:new(milky, body, '???'):position(130, 0)
    local bd = milky.panel:new(milky, body, " -"):position(100, 0):size(15, 15):button(milky, function (self, button) dec_inv(it) end)
    local bi = milky.panel:new(milky, body, " +"):position(170, 0):size(15, 15):button(milky, function (self, button) inc_inv(it) end)
    
    return body, value
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


function new_building(buiding_type, i, j)
    buildings_i[last_building] = i
    buildings_j[last_building] = j
    buildings_type[last_building] = buiding_type
    buildings_wealth_before_taxes[last_building] = 0
    buildings_wealth_after_taxes[last_building] = 0
    buildings_char_amount[last_building] = 0
    last_building = last_building + 1
end

function kingdom_income(t)
    local tmp = math.floor(BUDGET_RATIO[INVESTMENT_TYPE.HUNT] * t / 100)
    kingdom_wealth = kingdom_wealth + t - tmp
    hunt_budget = hunt_budget + tmp
end

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
    end
end

function new_char(hp, wealth, state, home) 
    chars_hp[last_char] = hp
    chars_wealth[last_char] = wealth
    chars_weapon[last_char] = 3
    chars_armour[last_char] = 1
    chars_state[last_char] = state 
    chars_target[last_char] = nil
    chars_home[last_char] = home
    chars_x[last_char] = buildings_i[chars_home[last_char]] * grid_size + grid_size/2
    chars_y[last_char] = buildings_j[chars_home[last_char]] * grid_size + grid_size/2
    chars_potions[last_char] = 0
    ALIVE_CHARS[last_char] = true
    last_char = last_char + 1
end

function new_tax_collector()
    new_char(50, 0, CHAR_STATE.TAXCOLLECTION, 1)
end

function new_hero(wealth)
    ALIVE_HEROES[last_char] = true
    new_char(100, wealth, CHAR_STATE.WANDERING, 1)
    chars_weapon[last_char - 1] = 2
end

function new_rat(nest)
    chars_hp[last_char] = 30
    chars_wealth[last_char] = 0
    chars_weapon[last_char] = 2
    chars_weapon_d[last_char] = 100
    chars_armour[last_char] = 1
    chars_armour_d[last_char] = 100
    chars_state[last_char] = CHAR_STATE.PROTECT_THE_LAIR
    chars_target[last_char] = nil
    chars_home[last_char] = nest
    chars_potions[last_char] = 0
    chars_x[last_char] = buildings_i[chars_home[last_char]] * grid_size + grid_size/2
    chars_y[last_char] = buildings_j[chars_home[last_char]] * grid_size + grid_size/2
    
    ALIVE_RATS[last_char] = true
    ALIVE_CHARS[last_char] = true
    
    last_char = last_char + 1
end

function love.draw()
    love.graphics.setColor(1, 1, 0)
    main_ui:draw()
    
    for i = 1, last_char - 1 do
        if (ALIVE_CHARS[i]) then
            love.graphics.circle('line', chars_x[i], chars_y[i], 2)
        end
    end
    
    for i = 1, last_building - 1 do
        love.graphics.rectangle('line', buildings_i[i] * grid_size, buildings_j[i] * grid_size, grid_size, grid_size)
    end
end

function buildings_x(i) 
    return buildings_i[i] * grid_size + grid_size/2
end

function buildings_y(i)
    return buildings_j[i] * grid_size + grid_size/2
end


function char_move_to_target(i)
    if chars_target == nil then
        return
    end
    local dx = chars_target[i].x - chars_x[i]
    local dy = chars_target[i].y - chars_y[i]
    local norm = math.sqrt(dx * dx + dy * dy)
    if (norm > 1) then
        chars_x[i] = chars_x[i] + dx / norm
        chars_y[i] = chars_y[i] + dy / norm
    else
        chars_x[i] = chars_x[i] + dx 
        chars_y[i] = chars_y[i] + dy 
        chars_target[i] = nil
    end
end

function char_buy_potions(i, shop)
    if chars_wealth[i] >= 10 then
        buildings_wealth_before_taxes[shop] = buildings_wealth_before_taxes[shop] + 10
        chars_wealth[i] = chars_wealth[i] - 10
        chars_potions[i] = chars_potions[i] + 1
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

time_passed = 0
tps = 20
tick = 1 / tps / 5

function love.update(dt)
    time_passed = time_passed + dt
    while time_passed > tick do
    time_passed = time_passed - tick
    
    -- chars update
    for i = 1, last_char - 1 do
        if ALIVE_CHARS[i] then
            if ((chars_state[i] == CHAR_STATE.WANDERING) or (chars_state[i] == CHAR_STATE.HUNT)) and chars_wealth[i] > 50 and chars_potions[i] < 4 then
                char_change_state(i, CHAR_STATE.BUY_POTIONS)
            end
            if chars_hp[i] < 60 and chars_state[i] ~= CHAR_STATE.PROTECT_THE_LAIR then
                char_drink_pot(i)
            end
            if chars_state[i] == CHAR_STATE.BUY_POTIONS then
                if chars_wealth[i] < 10 or chars_potions[i] >= 4 then
                    chars_state[i] = CHAR_STATE.WANDERING
                    chars_target[i] = nil
                elseif chars_target[i] == nil then
                    local closest_shop = 2 -- should rewrite to finding the closest shop
                    chars_target[i] = {}                
                    chars_target[i].x = buildings_x(closest_shop)
                    chars_target[i].y = buildings_y(closest_shop)
                elseif dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
                    local closest_shop = 2 -- should rewrite to finding the closest shop
                    char_buy_potions(i, closest_shop)
                else 
                    char_move_to_target(i)
                end
            end
        
            if chars_state[i] == CHAR_STATE.WANDERING then
                if (hunt_budget > 0) then
                    char_change_state(i, CHAR_STATE.HUNT)
                elseif chars_target[i] == nil then
                    chars_target[i] = {}
                    local dice = math.random() - 0.5
                    chars_target[i].x = dice * dice * dice * 400 + buildings_x(chars_home[i])
                    local dice = math.random() - 0.5
                    chars_target[i].y = dice * dice * dice * 400 + buildings_y(chars_home[i])
                elseif chars_target[i] ~= nil then
                    char_move_to_target(i)
                end
            end
            
            if chars_state[i] == CHAR_STATE.PROTECT_THE_LAIR then
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
                if (closest_hero ~= nil) and (from_home_dist < 410) then
                    chars_target[i] = {}
                    chars_target[i].x = chars_x[closest_hero]
                    chars_target[i].y = chars_y[closest_hero]
                    if curr_dist > 1 then 
                        char_move_to_target(i)
                    else
                        char_attack_char(i, closest_hero)
                    end
                elseif chars_target[i] == nil then
                    chars_target[i] = {}
                    local dice = math.random() - 0.5
                    chars_target[i].x = dice * dice * dice * 800 + buildings_x(chars_home[i])
                    local dice = math.random() - 0.5
                    chars_target[i].y = dice * dice * dice * 800 + buildings_y(chars_home[i])
                elseif chars_target[i] ~= nil then
                    char_move_to_target(i)
                end
            end
            
            if chars_state[i] == CHAR_STATE.TAXCOLLECTION then
                if chars_target[i] == nil then
                    if buildings_wealth_before_taxes[2] > 9 then
                        local closest_shop = 2
                        chars_target[i] = {}                
                        chars_target[i].x = buildings_x(closest_shop)
                        chars_target[i].y = buildings_y(closest_shop)
                    end
                elseif chars_target[i] ~= nil then
                    if dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
                        char_tax_building(i, 2)
                        char_change_state(i, CHAR_STATE.RETURNTAXES)
                    else 
                        char_move_to_target(i)
                    end
                end
            end
            
            if chars_state[i] == CHAR_STATE.RETURNTAXES then
                if chars_target[i] == nil then
                    local closest_tax_storage = 1
                    chars_target[i] = {}
                    chars_target[i].x = buildings_x(closest_tax_storage)
                    chars_target[i].y = buildings_y(closest_tax_storage)
                elseif chars_target[i] ~= nil then
                    if dist(chars_target[i].x, chars_target[i].y, chars_x[i], chars_y[i]) < 0.5 then
                        char_return_tax(i)
                        char_change_state(i, CHAR_STATE.TAXCOLLECTION)
                    else 
                        char_move_to_target(i)
                    end
                end
            end
            
            if chars_state[i] == CHAR_STATE.HUNT then
                if (hunt_budget < REWARD) then
                    char_change_state(i, CHAR_STATE.WANDERING)
                else 
                
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
                    chars_target[i] = {}
                    chars_target[i].x = chars_x[closest_rat]
                    chars_target[i].y = chars_y[closest_rat]
                    if curr_dist > 1 then 
                        char_move_to_target(i)
                    else
                        local tmp = char_attack_char(i, closest_rat)
                        if (tmp == CHAR_ATTACK_RESPONSE.KILL) then
                            char_recieve_reward(i)
                        end
                    end
                    chars_target[i] = nil
                end
                if (chars_target[i] == nil) and (closest_rat == nil) then
                    chars_target[i] = {}
                    local dice = math.random() - 0.5
                    chars_target[i].x = dice * dice * dice * 400 + buildings_x(chars_home[i])
                    local dice = math.random() - 0.5
                    chars_target[i].y = dice * dice * dice * 400 + buildings_y(chars_home[i])
                elseif closest_rat == nil then
                    char_move_to_target(i)
                end
                
                end
            end
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
    
    -- interface update
    
    end
    wealth_widget:update_label(tostring(kingdom_wealth))
    hunt_widget:update_label(tostring(hunt_budget))
    
    hunt_invest_value:update_label(tostring(BUDGET_RATIO[INVESTMENT_TYPE.HUNT]) .. '%')
    treasury_invest_value:update_label(tostring(BUDGET_RATIO[INVESTMENT_TYPE.TREASURY]) .. '%')
end

function char_change_state(i, state)
    chars_state[i] = state
    chars_target[i] = nil
end

function dist(a, b, c, d)
    local t1 = math.abs(a - c)
    local t2 = math.abs(b - d)
    return math.max(t1, t2) + t1 + t2
end

function char_dist(i, j)
    return dist(chars_x[i], chars_y[i], chars_x[j], chars_y[j])
end
function char_build_dist(i, j)
    return dist(chars_x[i], chars_y[i], buildings_x(j), buildings_y(j))
end

function love.mousepressed(x, y, button, istouch)
    milky:onClick(x, y, button)
end
