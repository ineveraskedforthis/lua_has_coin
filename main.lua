---@diagnostic disable: trailing-space
local milky = require "milky"
local globals = require "modules.constants"
Cell = require "modules.game_objects.cell"

local Building = require "modules.game_objects.building"
local UI = require "ui"
local Castle = require "modules.game_objects.castle"

local Character = require "modules.game_objects.character"



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

ObjectsManager = require "modules.managers.ObjectsManager"

RAT_BIRTH_SPEED = 10000
FOOD_COOLDOWN = 50000

function love.load()

    love.window.setMode(800, 600)   

    ---@class Agent
    ---@field character Character
    ---@field ai InstructionManager

    ---@class ObjectsManager
    OBJ_MANAGER = ObjectsManager:new()


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
        race = 'rat',
        gathering = 5
    }    
    TEMPLATE.ELO = {
        max_hp = 100,
        base_defense = 10,
        base_attack = 10,
        wealth = 0,
        race = 'elo',
        gathering = 1
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
        OBJ_MANAGER:new_agent(GAME_UI, TEMPLATE.ELO, zero_cell:pos())
    end


    --- rats testing 
    local rats_cell = Cell:new(5, 5)
    local rat_lair = Building:new(Cell:new(5, 5), "home", 100)
    add_building(rat_lair)

    local rat_origin = OBJ_MANAGER:new_agent(GAME_UI, TEMPLATE.RAT, rats_cell:pos())
    rat_origin.character:set_home(rat_lair)
    
    
    for i = -100, 200 do
        for j = -100, 200 do
            if (map_build_flag[i] == nil) or (map_build_flag[i][j] == nil) then
                local dice = math.random()
                if dice < 0.13 then
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


function love.draw()    
    GAME_UI:draw()
end



-- game logic loop
TIME_PASSED = 0
BASE_TICKS_PER_SECOND = 40
TICK = 1 / BASE_TICKS_PER_SECOND 
SPEED = 0
function UPDATE_GAME_SPEED(newSPEED)
    SPEED = newSPEED
end
DAY_MOD_100 = 0

love.frame = 0
result = 0
result_order = 0

function love.update(dt)
    TIME_PASSED = TIME_PASSED + dt * SPEED



    while TIME_PASSED > TICK do      
        start = love.timer.getTime()
        

        TIME_PASSED = TIME_PASSED - TICK
        DAY_MOD_100 = DAY_MOD_100 + 1
        if DAY_MOD_100 == 100 then
            castle:update()
            DAY_MOD_100 = 0    
        end       

        OBJ_MANAGER:update()
		
        for _, building in pairs(buildings) do
            building:update()
        end

        for _, food_obj in pairs(food) do
            food_obj.cooldown = math.max(0, food_obj.cooldown - 1)
        end

        love.frame = love.frame + 1
        result = result + love.timer.getTime() - start

            if love.frame > 10000 then
                love.frame = 0
                print("---------------------------------------")
                print("update for 10000 ticks")
                print(math.floor(result * 100) / 100 .. " seconds update")
                print(math.floor(result_order * 100) / 100 .. " seconds __check_food")
                print(OBJ_MANAGER.last_agent .. " last agent index")
                result = 0
                result_order = 0
            end
    end
    
    -- -- interface update
    -- GAME_UI.wealth_widget:update_label(tostring(castle.wealth))
    -- GAME_UI.hunt_widget:update_label(tostring(castle.hunt_budget))
    
    -- hunt_invest_value:update_label(tostring(castle.budget.hunt) .. '%')
    -- treasury_invest_value:update_label(tostring(castle.budget.treasury) .. '%')
    -- tax_value:update_label(tostring(castle.INCOME_TAX) .. '%')
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