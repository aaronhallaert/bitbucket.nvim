local command_util = require("bitbucket.utils.command")

---@class DiffLineArg
---@field from_hash string|nil
---@field to_hash string
---@field from_line number
---@field to_line number
---@field filename string

---@class Git
---@field callback? fun(output: table)
---@field sync? boolean
local Git = {}

Git.__index = Git

---@param o Git
function Git:new(o)
    local git = o

    return setmetatable(git, self)
end

---@param command string
function Git:_execute(command)
    if self.sync ~= nil or self.sync == true then
        return command_util.execute_sync(command)
    else
        return command_util.execute(command, self.callback)
    end
end

function Git:get_remote_url()
    self:_execute("git config --get remote.origin.url")
end

function Git:fetch_all()
    self:_execute("git fetch --all")
end

function Git:merge_base(source_hash, destination_hash)
    self:_execute("git merge-base " .. source_hash .. " " .. destination_hash)
end

---@param opt DiffLineArg
function Git:show_diff_line(opt)
    local command = ""
    local anchor = opt.to_line or opt.from_line

    if anchor == nil then
        return {}
    end

    if opt.from_hash == nil then
        command = command
            .. string.format(
                "git --no-pager show %s -L %d,%d:%s",
                opt.to_hash,
                opt.from_line,
                opt.to_line,
                opt.filename
            )
    else
        command = command
            .. string.format(
                "git --no-pager show %s..%s -L %d,%d:%s",
                opt.from_hash,
                opt.to_hash,
                opt.from_line,
                opt.to_line,
                opt.filename
            )
    end

    return self:_execute(command)
end

return Git
