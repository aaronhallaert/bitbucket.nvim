local Buffer = require("bitbucket.ui.buffer")

---@class BitbucketState
---@field buffers Buffer[]
---@field current_pr PullRequest|nil
local BitbucketState = {}
BitbucketState.__index = BitbucketState

---@return BitbucketState
function BitbucketState:new(o)
    local obj = o or { buffers = {} }
    return setmetatable(obj, self)
end

---@param buffer Buffer
function BitbucketState:add_buffer(buffer)
    table.insert(self.buffers, buffer)
end

---@param buf_id number
---@return Buffer|nil
function BitbucketState:get_buffer(buf_id)
    for _, buffer in ipairs(self.buffers) do
        if buffer.buf_id == buf_id then
            return buffer
        end
    end
end

return BitbucketState:new()
