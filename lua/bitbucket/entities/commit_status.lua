local bubble = require("bitbucket.ui.bubble")

---@class CommitStatus
---@field key string
---@field name string
---@field url string
---@field state "FAILED"|"INPROGRESS"|"SUCCESSFUL"
local CommitStatus = {}
CommitStatus.__index = CommitStatus

---@param o CommitStatus
---@return CommitStatus
function CommitStatus:new(o)
    local obj = o
    return setmetatable(obj, self)
end

function CommitStatus:display()
    local contents = {}

    local state_bubble = {}
    if self.state == "FAILED" then
        state_bubble = bubble.make_bubble("Failed", "red")
    elseif self.state == "INPROGRESS" then
        state_bubble = bubble.make_bubble("In Progress", "yellow")
    elseif self.state == "SUCCESSFUL" then
        state_bubble = bubble.make_bubble("Success", "green")
    end

    table.insert(state_bubble, { " - " .. self.name, "Normal" })

    table.insert(contents, state_bubble)
    return contents
end

return CommitStatus
