local utils = require("bitbucket.utils")
local M = {}

--- Executes a command and returns the output
--- @param command string
--- @return table returns empty string upon error
M.execute = function(command)
    local handle = io.popen(command)

    if handle == nil then
        return {}
    end

    local output = handle:read("*a")
    handle:close()

    local output_table = utils.split_string(output, "\n")

    -- remove last empty line
    if output_table[#output_table] == "" then
        table.remove(output_table, #output_table)
    end

    return output_table
end

return M
