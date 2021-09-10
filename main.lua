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
    POTION_PRICE = 10
    
    INVESTMENT_TYPE = {}
    INVESTMENT_TYPE.TREASURY = 0
    INVESTMENT_TYPE.HUNT = 1
    
    BUDGET_RATIO = {}
    BUDGET_RATIO[INVESTMENT_TYPE.TREASURY] = 100
    BUDGET_RATIO[INVESTMENT_TYPE.HUNT] = 0

    
    -- character states

    
    CHAR_STATE = {}
    CHAR_STATE.WANDERING = new_state_id()
    CHAR_STATE.FIGHT = new_state_id()
    CHAR_STATE.TAXCOLLECTION = new_state_id()
    CHAR_STATE.RETURNTAXES = new_state_id()
    CHAR_STATE.BUY_POTIONS = new_state_id()
    CHAR_STATE.HUNT = new_state_id()
    CHAR_STATE.PROTECT_THE_LAIR = new_state_id()
    
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









-- ui manipulations

function create_invest_row(parent, label, it)
    local body = milky.panel:new(milky, parent, nil, nil)
    
    local label = milky.panel:new(milky, body, label):position(0, 0)
    local value = milky.panel:new(milky, body, '???'):position(130, 0)
    local bd = milky.panel:new(milky, body, " -"):position(100, 0):size(15, 15):button(milky, function (self, button) dec_inv(it) end)
    local bi = milky.panel:new(milky, body, " +"):position(170, 0):size(15, 15):button(milky, function (self, button) inc_inv(it) end)
    
    return body, value
end











-- draw loop
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



















-- game logic loop
time_passed = 0
tps = 20
tick = 1 / tps / 10--/ 50

function love.update(dt)
    time_passed = time_passed + dt
    while time_passed > tick do
    time_passed = time_passed - tick
    
    -- chars update
    for i = 1, last_char - 1 do
        if ALIVE_CHARS[i] then
            
            if chars_occupation[i] == CHAR_OCCUPATION.HUNTER then
                AGENT_LOGIC[CHAR_OCCUPATION.HUNTER](i)
            end
            
            if chars_occupation[i] == CHAR_OCCUPATION.TAX_COLLECTOR then
                AGENT_LOGIC[CHAR_OCCUPATION.TAX_COLLECTOR](i)
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

function love.mousepressed(x, y, button, istouch)
    milky:onClick(x, y, button)
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
    last_char = last_char + 1
end

function new_tax_collector()
    new_char(50, 0, CHAR_STATE.TAX_COLLECTOR_WAIT_IN_CASTLE, 1)
    chars_occupation[last_char - 1] = CHAR_OCCUPATION.TAX_COLLECTOR
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
    chars_target[last_char] = {}
    chars_home[last_char] = nest
    chars_potions[last_char] = 0
    chars_x[last_char] = buildings_i[chars_home[last_char]] * grid_size + grid_size/2
    chars_y[last_char] = buildings_j[chars_home[last_char]] * grid_size + grid_size/2
    chars_occupation[last_char] = CHAR_OCCUPATION.RAT
    ALIVE_RATS[last_char] = true
    ALIVE_CHARS[last_char] = true
    
    last_char = last_char + 1
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
        buildings_wealth_before_taxes[shop] = buildings_wealth_before_taxes[shop] + 10
        chars_wealth[i] = chars_wealth[i] - POTION_PRICE
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

function char_change_state(i, state)
    if (chars_state[i] == state) then
        return
    end
    chars_state[i] = state
    chars_target[i].x = nil
    chars_target[i].y = nil
    chars_state_target[i] = nil
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
HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION = -1
HUNTER_DESITE_TO_HUNT_FOR_REWARD = 3
HUNTER_DESITE_TO_HUNT_WITHOUT_REWARD = -3
HUNTER_DESIRE_TO_CONTINUE_HUNT = 1
HUNTER_NO_RATS_HUNT_COOLDOWN = 100

-- HUNTER STATES
CHAR_STATE.HUNTER_BUY_POTION = new_state_id()
CHAR_STATE.HUNTER_HUNT = new_state_id()
CHAR_STATE.HUNTER_WANDER = new_state_id()

-- HUNTER RESPONCES
HUNTER_RESPONCES = {}
HUNTER_RESPONCES.ON_MY_WAY = 1
HUNTER_RESPONCES.FOUND_TARGET = 2
HUNTER_RESPONCES.BOUGHT_POTION = 3
HUNTER_RESPONCES.TARGET_REACHED = 4
HUNTER_RESPONCES.NO_RATS = 5

AGENT_LOGIC[CHAR_OCCUPATION.HUNTER] = function (i)
    if chars_hp[i] < 60 then
        char_drink_pot(i)
    end  
    
    if chars_state[i] == nil then
        char_change_state(i, CHAR_STATE.HUNTER_WANDER)
    end
    
    local hunting_desire = 0
    
    if chars_cooldown[i] > 0 then
        hunting_desire = hunting_desire - 1000
        chars_cooldown[i] = chars_cooldown[i] - 1
    end
    
    if hunt_budget >= REWARD then
        hunting_desire = hunting_desire + HUNTER_DESITE_TO_HUNT_FOR_REWARD
    else
        hunting_desire = hunting_desire + HUNTER_DESITE_TO_HUNT_WITHOUT_REWARD
    end
    
    if chars_state[i] == CHAR_STATE.HUNTER_HUNT then
        hunting_desire = hunting_desire + HUNTER_DESIRE_TO_CONTINUE_HUNT
    end
    
    hunting_desire = hunting_desire + (HUNTER_DESIRED_AMOUNT_OF_POTIONS - chars_potions[i]) * HUNTER_DESIRE_TO_HUNT_PER_MISSING_POTION
    
    if hunting_desire > 0 then
        char_change_state(i, CHAR_STATE.HUNTER_HUNT)
    else 
        if (chars_wealth[i] > 2 * POTION_PRICE) and (chars_potions[i] < 3) then
            char_change_state(i, CHAR_STATE.HUNTER_BUY_POTION)
        else 
            char_change_state(i, CHAR_STATE.HUNTER_WANDER)
        end
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

end