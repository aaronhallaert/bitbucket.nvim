local Env = require("bitbucket.utils.env")
local M = {}

M.commands = {
    pull = {
        reviewing = function()
            require("bitbucket.commands.pullrequests").reviewing()
        end,
        mine = function()
            require("bitbucket.commands.pullrequests").mine()
        end,
        comment = function()
            require("bitbucket.commands.pullrequests").comment()
        end,
        approve = function()
            require("bitbucket.commands.pullrequests").approve()
        end,
        query = function(...)
            q = { ... }
            q = table.concat(q, " ")

            vim.print("query: " .. q)
            require("bitbucket.commands.pullrequests").query(q)
        end,
    },
    log = function()
        require("bitbucket.utils.logger"):show()
    end,
    auth = function()
        Env:auth()
    end,
}

M.bitbucket = function(object, action, ...)
    if object ~= "auth" and not Env:setup() then
        return
    end

    if object ~= nil and action ~= nil then
        M.commands[object][action](...)
    elseif object ~= nil and action == nil then
        M.commands[object](...)
    end
end

M.completion = function(argLead, cmdLine)
    local command_keys = vim.tbl_keys(M.commands)

    local get_options = function(options)
        local valid_options = {}
        for _, option in pairs(options) do
            if string.sub(option, 1, #argLead) == argLead then
                table.insert(valid_options, option)
            end
        end
        return valid_options
    end

    local parts = vim.split(vim.trim(cmdLine), " ")
    if #parts == 1 then
        return command_keys
    elseif #parts == 2 and not vim.tbl_contains(command_keys, parts[2]) then
        return get_options(command_keys)
    elseif
        (#parts == 2 and vim.tbl_contains(command_keys, parts[2]))
        or #parts == 3
    then
        local subcommands = M.commands[parts[2]]
        if subcommands then
            if type(subcommands) == "table" then
                return get_options(vim.tbl_keys(subcommands))
            end
        end
    end

    return {}
end

return M
