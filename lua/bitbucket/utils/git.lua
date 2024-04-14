local command_util = require("bitbucket.utils.command")
local utils = require("bitbucket.utils")

local M = {}

M.remote_url = function()
    return command_util.execute("git config --get remote.origin.url")[1]
end

---@class DiffLineArg
---@field from_hash string|nil
---@field to_hash string
---@field from_line number
---@field to_line number
---@field filename string

---@param opt DiffLineArg
---@return table
M.show_diff_line = function(opt)
    local command = ""
    local anchor = opt.to_line or opt.from_line

    if anchor == nil then
        return {}
    end

    M.fetch_all()

    if opt.from_hash == nil then
        command = string.format(
            "git --no-pager show %s -L %d,%d:%s",
            opt.to_hash,
            opt.from_line,
            opt.to_line,
            opt.filename
        )
    else
        command = string.format(
            "git --no-pager show %s..%s -L %d,%d:%s",
            opt.from_hash,
            opt.to_hash,
            opt.from_line,
            opt.to_line,
            opt.filename
        )
    end

    return command_util.execute(command)
end

---@param remote string
---@return string|nil workspace
---@return string|nil repo
M.parse_remote_ = function(remote)
    local repo = utils.split_string(remote, ":")[2]
    if repo == nil then
        vim.print("No remote found")
        return nil, nil
    end
    repo, _ = string.gsub(repo, "%.git", "")
    repo = utils.split_string(repo, "/")
    return repo[1], repo[2]
end

---@return string|nil workspace
---@return string|nil repo
M.repo = function()
    local output = M.remote_url()
    return M.parse_remote_(output)
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
