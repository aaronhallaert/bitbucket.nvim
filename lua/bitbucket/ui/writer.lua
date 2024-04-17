---@class Writer
local Writer = {}

Writer.__index = Writer

function Writer:new()
    local writer = setmetatable({}, self)

    return writer
end

return Writer:new()
