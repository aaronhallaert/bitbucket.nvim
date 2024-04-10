local command_util = require("bitbucket.utils.command")
local utils = require("bitbucket.utils")

local M = {}

---@return string|nil workspace
---@return string|nil repo
M.repo = function()
    local output = command_util.execute("git config --get remote.origin.url")[1]

    local repo = utils.split_string(output, ":")[2]
    if repo == nil then
        vim.print("No remote found")
        return nil, nil
    end

    repo, _ = string.gsub(repo, ".git", "")
    repo = utils.split_string(repo, "/")
    return repo[1], repo[2]
end

return M
