local Buffer = require("bitbucket.ui.buffer")

---@class SelectedPR
---@field pr PullRequest
---@field buffer Buffer

---@class BitbucketState
---@field buffers Buffer[]
---@field selected SelectedPR|nil
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

---@param pr PullRequest
---@param buffer Buffer
function BitbucketState:set_selected(pr, buffer)
    self.selected = { pr = pr, buffer = buffer }
end

return BitbucketState:new()
