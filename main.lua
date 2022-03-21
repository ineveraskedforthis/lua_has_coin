---@diagnostic disable: trailing-space
local milky = require "milky"
local hunter = require "modules.hunter"
local globals = require "modules.constants"
local Building = require "modules.building"
local UI = require "ui"
local Castle = require "modules.castle"
local InstructionManager = require "modules.instructions._InstructionManager"


AgentInstruction = require "modules.instructions._AgentInstructionClass"
InstructionNode = require "modules.instructions._InstructionNodeClass"
Character = require "modules.character"
require "modules.instructions.Events"
GatherFoodInstruction = require "modules.instructions.GatherEat"
SleepInstruction = require "modules.instructions.Sleep"

function love.load()
    love.window.setMode(800, 600)   

    -- data structs init
    init_food_array()

    -- flags
    map_build_flag = {}
    
    -- lists
    
    ALIVE_RATS = {}
    ALIVE_HEROES = {}
    ALIVE_CHARS = {}

    ---@class Agent
    ---@field agent Character
    ---@field ai InstructionManager

    ---@type Agent[]
    agents = {}

    ---@type Building[]
    buildings = {}    
    
    -- game data
    zero_cell = {x=30, y=30}
    castle = Castle:new(zero_cell, 100, 500)
    table.insert(agents, #agents + 1, new_agent(Character:new(100, 100, convert_cell_to_coord(zero_cell), 10, 10, false)))
    table.insert(agents, #agents + 1, new_agent(Character:new(100, 100, convert_cell_to_coord(zero_cell), 10, 10, false)))
    table.insert(agents, #agents + 1, new_agent(Character:new(100, 100, convert_cell_to_coord(zero_cell), 10, 10, false)))
    table.insert(agents, #agents + 1, new_agent(Character:new(100, 100, convert_cell_to_coord(zero_cell), 10, 10, false)))

    game_ui = UI:new(true)
    
    for i = 1, 100 do
        for j = 1, 100 do
            if (map_build_flag[i] == nil) or (map_build_flag[i][j] == nil) then
                local dice = math.random()
                if dice > 0.90 then
                    new_food(i, j)
                end
            end
        end
    end
end

---comment
---@param character Character
---@return Agent
function new_agent(character)
    local manager = InstructionManager:new(character)
    return {agent= character, ai= manager}
end


function love.draw()    
    game_ui:draw()
end



---@class Cell
---@field x number
---@field y number

---comment
---@param cell Cell
---@return Position
function convert_cell_to_coord(cell)
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x = cell.x * grid_size + grid_size/2, y = cell.y * grid_size + grid_size/2}
end

---comment
---@param position Position
---@return Cell
function convert_coord_to_cell(position)
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x= math.floor(position.x / grid_size), y= math.floor(position.y / grid_size)}
end



-- game logic loop
time_passed = 0
tps = 20
tick = 1 / tps / 20 --/ 50

function love.update(dt)
    time_passed = time_passed + dt
    while time_passed > tick do
        time_passed = time_passed - tick
        
        -- chars update


        for _, agent in pairs(agents) do
            local event = agent.agent:update()
            agent.ai:update(agent.agent)
        end        
		
        for _, building in pairs(buildings) do
            building:update()
        end

        for _, food_obj in pairs(food) do
            food_obj.cooldown = math.max(0, food_obj.cooldown - 1)
        end
    end
    
    -- interface update
    game_ui.wealth_widget:update_label(tostring(castle.wealth))
    game_ui.hunt_widget:update_label(tostring(castle.hunt_budget))
    
    hunt_invest_value:update_label(tostring(castle.budget.hunt) .. '%')
    treasury_invest_value:update_label(tostring(castle.budget.treasury) .. '%')
    inc_tax_value:update_label(tostring(castle.INCOME_TAX) .. '%')
end


function init_food_array()
    last_food = 1
    ---@type Target[]
    food = {}
end

last_state_id = 0
function new_state_id()
    last_state_id = last_state_id + 1
    return last_state_id
end


-- getters
function dist(a, b)
    local pos1 = a:pos()
    local pos2 = b:pos()
    local t1 = math.abs(pos1.x - pos2.x)
    local t2 = math.abs(pos1.y - pos2.y)
    return math.max(t1, t2) + t1 + t2
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

function get_new_building_location(castle)
    local r = 2
    local c_x, c_y = castle.cell.x, castle.cell.y
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


---comment
---@param hp number
---@param wealth number
---@param home Building|Castle
---@return Character
function new_char(hp, wealth, home) 
    local char = Character:new(hp, wealth, home, 5, 5, false)
    local ai = Hunter_AI:new()
    char.ai = ai
    char.ai:choose_algo(char)
    return char
end

function new_food(x, y)
    food[last_food] = Target:new(convert_cell_to_coord({x = x, y= y}))
    food[last_food].cell = {x = x, y= y}
    food[last_food].cooldown = 0
    last_food = last_food + 1
end

function new_hero(wealth)
    ALIVE_HEROES[last_char] = true
    local char = new_char(100, wealth, castle)
    char.weapon.level = 5
    char.armour.level = 5
    return last_char - 1
end


function new_building(i, j, progress, owner)
    if map_build_flag[i] == nil then
        map_build_flag[i] = {}
    end
    map_build_flag[i][j] = true
    buildings[last_building] = Building:new({x=i, y=j}, 0, progress, owner)
    last_building = last_building + 1
    return last_building - 1
end