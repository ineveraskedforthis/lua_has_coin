local InstructionManager = require "modules.instructions._InstructionManager"

---@class ObjectsManager
---@field agents Agent[]
---@field last_agent number
---@field chunk_size number
---@field food_chunk table
local ObjectsManager = {}
ObjectsManager.__index = ObjectsManager

function ObjectsManager:new()
    _  = {}
    _.agents = {}
    _.last_agent = 0
    _.chunk_size = 10
    _.food_chunk = {}
    setmetatable(_, ObjectsManager)
    return _
end

---Creates a new agent, adds it to UI and returns it.
---@param ui UI
---@param template table
---@param position Position
---@param home Building|nil
---@return Agent
function ObjectsManager:new_agent(ui, template, position, home)
    local character = Character:new(template, position)
    character:set_home(home)
    local manager = InstructionManager:new(character)
    local agent = {character= character, ai= manager}

    self.agents[self.last_agent + 1] = agent
    self.last_agent = self.last_agent + 1
    ui.table_of_units:add_unit(self.last_agent)
    return agent
end

function ObjectsManager:kill_agent(index)
    self:remove_agent(index)
end

function ObjectsManager:remove_agent(index)
    GAME_UI.table_of_units:remove_unit(index)
    self.agents[index] = nil
end


function ObjectsManager:update()
    local agents_to_delete = {}
    local agents_to_create = {}

    for _, agent in pairs(self.agents) do
        local responce = agent.character:update()
        if responce == nil then
            agent.ai:update(agent.character)
        elseif responce.type == "death" then
            table.insert(agents_to_delete, _)
        elseif responce.type == "new_agent" then
            table.insert(agents_to_create, responce)
        end
    end

    for k, v in pairs(agents_to_delete) do
        self:kill_agent(v)
    end
    for k, v in pairs(agents_to_create) do
        self:new_agent(GAME_UI, v.template, v.position, v.home)
    end
end

function ObjectsManager:generate_food()
    for i = -100, 200 do
        for j = -100, 200 do
            if (map_build_flag[i] == nil) or (map_build_flag[i][j] == nil) then
                local dice = math.random()
                if dice < 0.13 then
                    self:new_food(i, j)
                end
            end
        end
    end
end

function ObjectsManager:new_food(x, y)
    local cell = Cell:new(x, y)
    local last_food = #food + 1
    food[last_food] = Target:new(cell:pos())
    food[last_food].cell = cell
    food[last_food].cooldown = 0

    local i, j = self:get_chunk_from_cell(cell)
    if self.food_chunk[i] == nil then
        self.food_chunk[i] = {}
    end
    if self.food_chunk[i][j] == nil then
        self.food_chunk[i][j] = {}
    end
    table.insert(self.food_chunk[i][j], last_food)
end

function ObjectsManager:get_chunk_from_cell(cell)
    local i = math.floor(cell.x / self.chunk_size)
    local j = math.floor(cell.y / self.chunk_size)
    return i, j
end

function ObjectsManager:get_chunk_from_position(position)
    local cell = Cell:new_from_coordinate(position)
    return self:get_chunk_from_cell(cell)
end

function ObjectsManager:check_food(target)
    local i, j = self:get_chunk_from_position(target:pos())
    for di = -1, 1 do
        for dj = -1, 1 do
            local x = i + di
            local y = j + dj
            if (self.food_chunk[x] ~= nil) and (self.food_chunk[x][y] ~= nil) then
                for _, f in pairs(self.food_chunk[x][y]) do
                    local food_obj = food[f]
                    if (target:__dist_to(food_obj) < 20) and (food_obj.cooldown == 0) then
                        return Event_TargetFound(food_obj)
                    end
                end 
            end
        end
    end
    return nil
end

return ObjectsManager