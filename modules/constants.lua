function readonlytable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   });
end

function enum(table)
    local length = #table
    for i = 1, length do
        local v = table[i]
        table[v] = i
    end
    return table
end


globals = readonlytable {
    CONSTANTS = readonlytable {
        GRID_SIZE = 10,
        POTION_SPOILING_SPEED = 0.1,
        WEAPON_SPOILING_SPEED = 0.1,
        ARMOUR_SPOILING_SPEED = 0.1,
        WORLD_SIZE = 300,
    },
}

return globals