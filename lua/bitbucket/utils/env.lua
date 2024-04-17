local Git = require("bitbucket.utils.git")
local utils = require("bitbucket.utils")

---@class Env
---@field user AppUserInfo
---@field remote? string
---@field workspace? string
---@field repo? string
---@field _remote_initialized boolean
local Env = {}

Env.__index = Env

function Env:new(e)
    local env = e or {}

    return setmetatable(env, self)
end

function Env:setup()
    local config = require("bitbucket.utils.config")

    self:set_user(config.user_data())

    Git:new({
        callback = function(output)
            local remote = output[1]
            self:set_remote(remote)
        end,
    }):get_remote_url()
end

function Env:set_workspace(workspace)
    self.workspace = workspace
end

function Env:set_user(user)
    self.user = user
end

function Env:_parse_remote(remote)
    local repo = utils.split_string(remote, ":")[2]
    if repo == nil then
        return nil, nil
    end
    repo, _ = string.gsub(repo, "%.git", "")
    repo = utils.split_string(repo, "/")
    return repo[1], repo[2]
end

function Env:set_remote(remote)
    self._remote_initialized = true
    self.remote = remote

    if remote == nil then
        return
    end

    self.workspace, self.repo = self:_parse_remote(remote)
end

---@return boolean bitbucket
---@return boolean initialized
function Env:is_bitbucket()
    if self.remote == nil then
        return false, self._remote_initialized
    end

    local find_start, _ = string.find(self.remote, "%@bitbucket")

    return find_start ~= nil, self._remote_initialized
end

return Env:new()
