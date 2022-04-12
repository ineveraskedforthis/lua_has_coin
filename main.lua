---@diagnostic disable: trailing-space
local milky = require "milky"
local hunter = require "modules.hunter"
local globals = require "modules.constants"
local Building = require "modules.building"
local UI = require "ui"
local Castle = require "modules.castle"
Character = require "modules.character"

local InstructionManager = require "modules.instructions._InstructionManager"

require "modules.instructions._Events"

Order = require "modules._Order"
require "modules._Orders"

require "modules.instructions._Conditions"
require "modules.instructions._Actions"


AgentInstruction = require "modules.instructions._AgentInstructionClass"
InstructionNode = require "modules.instructions._InstructionNodeClass"


GatherFoodInstruction = require "modules.instructions.GatherEat"
SleepInstruction = require "modules.instructions.Sleep"
OpenShopInstruction = require "modules.instructions.OpenShop"
SleepPaidInstruction = require "modules.instructions.SleepPaid"
WanderInstruction = require "modules.instructions.Wander"
SellFoodInstruction = require "modules.instructions.SellFood"
BuyEatInstruction = require "modules.instructions.BuyFood"
GetJobInstruction = require "modules.instructions.TakeTaxCollectJob"
GetPaidInstruction = require "modules.instructions.GetPayment"
CollectTaxInstruction = require "modules.instructions.CollectTax"
GetMoneyFromShopInstruction = require "modules.instructions.GetMoneyFromShop"
SellPotionInstruction = require "modules.instructions.MakePotionForSell"
MakePotionInstruction = require "modules.instructions.MakePotion"
BuyPotionInstruction = require "modules.instructions.BuyPotion"

require "modules.instructions._Utility"

UtilitySources = {}
UtilitySources.rat = require "modules.instructions._UtilityRat"
UtilitySources.elo = require "modules.instructions._UtilityElo"

RAT_BIRTH_SPEED = 5000
FOOD_COOLDOWN = 100000

function love.load()
    love.window.setMode(800, 600)   

    ---@class Agent
    ---@field agent Character
    ---@field ai InstructionManager

    ---@type Agent[]
    agents = {}

    ---@type Building[]
    buildings = {} 

    --- set up UI
    GAME_UI = UI:new(false)

    --- templates

    TEMPLATE = {}
    TEMPLATE.RAT = {
        max_hp = 50,
        base_defense = 5,
        base_attack = 5,
        wealth = 0,
        race = 'rat'
    }    
    TEMPLATE.ELO = {
        max_hp = 100,
        base_defense = 10,
        base_attack = 10,
        wealth = 0,
        race = 'elo'
    }

    -- data structs init
    init_food_array()

    -- flags
    map_build_flag = {}
    
    -- lists
    
    ALIVE_RATS = {}
    ALIVE_HEROES = {}
    ALIVE_CHARS = {}

   
    
    -- game data
    zero_cell = Cell:new(30, 30)
    castle = Castle:new(zero_cell:clone(), 100, 500)

    for i = 1, 5 do
        CREATE_CHARACTER(TEMPLATE.ELO, zero_cell:pos())
    end

    local rich_character = Character:new(TEMPLATE.ELO, zero_cell:pos())
    rich_character.traits.business_ambition = true
    rich_character:add_wealth(1000)
    table.insert(agents, #agents + 1, NEW_AGENT(rich_character))

    local poor_ambitious_character = Character:new(TEMPLATE.ELO, zero_cell:pos())
    poor_ambitious_character.traits.business_ambition = true
    poor_ambitious_character.traits.long_term_planning = 20
    table.insert(agents, #agents + 1, NEW_AGENT(poor_ambitious_character))

    local alchemist_1 = Character:new(TEMPLATE.ELO, zero_cell:pos())
    alchemist_1.skill.alchemist = 5
    alchemist_1.traits.long_term_planning = 10
    table.insert(agents, #agents + 1, NEW_AGENT(alchemist_1))
    
    local alchemist_2 = Character:new(TEMPLATE.ELO, zero_cell:pos())
    alchemist_2.skill.alchemist = 5
    alchemist_2.traits.long_term_planning = 10
    table.insert(agents, #agents + 1, NEW_AGENT(alchemist_2))
    

    --- rats testing 
    local rats_cell = Cell:new(5, 5)
    ---@type Character
    local rat_king = Character:new(TEMPLATE.RAT, rats_cell:pos())
    local rat_lair = Building:new(Cell:new(5, 5), "home", 100, rat_king)
    rat_king:set_home(rat_lair)
    table.insert(agents, #agents + 1, NEW_AGENT(rat_king)) 
    add_building(rat_lair)
    
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
---@param x number
---@param y number
function new_position(x, y)
    return {x= x, y= y}
end


function CREATE_CHARACTER(template, position, home)
    local character = Character:new(template, position)
    character:set_home(home)
    local agent = NEW_AGENT(character)
    table.insert(agents, #agents + 1, agent)
    GAME_UI.table_of_units:add_unit(#agents)
    return agent
end

---comment
---@param character Character
---@return Agent
function NEW_AGENT(character)
    ---@type InstructionManager
    local manager = InstructionManager:new(character)
    return {agent= character, ai= manager}
end


function love.draw()    
    GAME_UI:draw()
end



---@class Cell
---@field x number
---@field y number
Cell = {}
Cell.__index = Cell
---Creates new cell
---@param x number
---@param y number
function Cell:new(x, y)
    _ = {x=x, y=y}
    setmetatable(_, Cell)
    return _
end
function Cell:pos()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return {x = self.x * grid_size + grid_size/2, y = self.y * grid_size + grid_size/2}
end
function Cell:clone()
    _ = {x=self.x, y=self.y}
    setmetatable(_, Cell)
    return _
end
function Cell:center()
    local grid_size = globals.CONSTANTS.GRID_SIZE
    local shift = grid_size / 2
    return {x = self.x * grid_size + shift, y = self.y * grid_size + shift}
end
---comment
---@param position Position
---@return Cell
function Cell:new_from_coordinate(position)
    local grid_size = globals.CONSTANTS.GRID_SIZE
    return Cell:new(math.floor(position.x / grid_size), math.floor(position.y / grid_size))
end



-- game logic loop
TIME_PASSED = 0
BASE_TICKS_PER_SECOND = 20
TICK = 1 / BASE_TICKS_PER_SECOND 
SPEED = 0
function UPDATE_GAME_SPEED(newSPEED)
    SPEED = newSPEED
end
DAY_MOD_100 = 0
function love.update(dt)
    TIME_PASSED = TIME_PASSED + dt * SPEED
    while TIME_PASSED > TICK do
        TIME_PASSED = TIME_PASSED - TICK
        DAY_MOD_100 = DAY_MOD_100 + 1
        if DAY_MOD_100 == 100 then
            castle:update()
            DAY_MOD_100 = 0    
        end       

        for _, agent in pairs(agents) do
            agent.agent:update()
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
    GAME_UI.wealth_widget:update_label(tostring(castle.wealth))
    GAME_UI.hunt_widget:update_label(tostring(castle.hunt_budget))
    
    hunt_invest_value:update_label(tostring(castle.budget.hunt) .. '%')
    treasury_invest_value:update_label(tostring(castle.budget.treasury) .. '%')
    tax_value:update_label(tostring(castle.INCOME_TAX) .. '%')
end


function init_food_array()
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


function new_food(x, y)
    local cell = Cell:new(x, y)
    local last_food = #food + 1
    food[last_food] = Target:new(cell:pos())
    food[last_food].cell = cell
    food[last_food].cooldown = 0
end


---Adds a new building into update loop
function add_building(building)
    table.insert(buildings, #buildings + 1, building)
end