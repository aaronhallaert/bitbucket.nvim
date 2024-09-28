local Logger = require("bitbucket.utils.logger")
local utils = require("bitbucket.utils")
local M = {}

--- Executes a command and returns the output
---@return table output
M.execute_sync = function(command)
    command = command .. " 2>/dev/null"
    local handle = io.popen(command)

    if handle == nil then
        return {}
    end

    local output = handle:read("*a")
    handle:close()

    local output_table = utils.split_string(output, "\n")

    if output_table[#output] == "" then
        table.remove(output_table, #output)
    end

    return output_table
end

--- @param command string
--- @param on_success? fun(output: table)
--- @param on_failure? fun()
M.execute = function(command, on_success, on_failure)
    local content = {}
    vim.fn.jobstart(command, {
        on_stdout = function(_, data)
            table.insert(content, data)
        end,
        on_exit = function(_, exit_code, _)
            if exit_code == 0 then
                if on_success ~= nil then
                    on_success(vim.tbl_flatten(content))
                end
            else
                Logger:log(
                    "command:execute",
                    { command = command, exit_code = exit_code }
                )

                if on_failure ~= nil then
                    on_failure()
                end
            end
        end,
    })
end

return M
