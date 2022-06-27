---@class Contract
---@field id number
---@field character Character
---@field goal "rat"
---@field expires_at number
---@field reward Character
---@field finished boolean
Contract = {}
Contract.__index = Contract

function Contract:new(id, character, goal, reward, expires_at)
    _ = {}
    _.id = id
    _.character = character
    _.goal = goal
    _.reward = reward
    _.expires_at = expires_at
    _.finished = false
    print("expires at", expires_at)
    setmetatable(_, Contract)
    return _
end