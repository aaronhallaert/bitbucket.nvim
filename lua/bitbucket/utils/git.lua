local command_util = require("bitbucket.utils.command")
local utils = require("bitbucket.utils")

local M = {}

M.remote_url = function()
    return command_util.execute("git config --get remote.origin.url")[1]
end

---@return string|nil workspace
---@return string|nil repo
M.repo = function()
    local output = M.remote_url()

    local repo = utils.split_string(output, ":")[2]
    if repo == nil then
        vim.print("No remote found")
        return nil, nil
    end

    repo, _ = string.gsub(repo, ".git", "")
    repo = utils.split_string(repo, "/")
    return repo[1], repo[2]
end

M.is_bitbucket = function()
    local remote = M.remote_url()
    if remote == nil then
        return false
    end

    local find_start, _ = string.find(remote, "%@bitbucket")

    return find_start ~= nil
end

M.fetch_all = function()
    command_util.execute("git fetch --all")
end

return M
