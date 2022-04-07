---@class Order
---@field name string
---@field action function
---@field notification "food"|"space"|nil
---@field flag_wander boolean
Order = {}
Order.__index = Order

---comment
---@param name string
---@param action function
---@param notification "food"|"space"|nil
---@param flag_wander boolean
function Order:new(name, action, notification, flag_wander)
    _ = {}
    _.name = name
    _.action = action
    _.notification = notification
    _.flag_wander = flag_wander
    setmetatable(_, Order)
    return _
end

function Order:set_up(character)
    if self.flag_wander then
        character:__set_random_target_circle()
    end
end

---Executes order on character
---@param character Character
---@return Event
function Order:execute(character)
    if self.notification == "food" then
        food = character:__check_food()
        if food ~= nil then
            character:set_target(food.target)
            return food
        end
    end
    if self.notification == "space" then
        space = character:__check_space()
        if space ~= nil then
            character:set_target(space.target)
            return space
        end
    end

    return self.action(character)
end

return Order