---@class ThreadMeta
---@field mark_id number
---@field start_line_mark number
---@field end_line_mark number
---@field path string
---@field line number

local ThreadMeta = {}
ThreadMeta.__index = ThreadMeta

---@return ThreadMeta
function ThreadMeta:new(opts)
    local this = {
        id = opts.id,
        path = opts.path,
        line = opts.line,
    }

    setmetatable(this, self)
    return this
end

return ThreadMeta
