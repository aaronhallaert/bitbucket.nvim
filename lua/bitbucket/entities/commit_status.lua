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
    table.insert(contents, { "## " .. self.name, "Title" })

    if self.state == "FAILED" then
        table.insert(contents, { self.state, "BitbucketFailingTest" })
    elseif self.state == "INPROGRESS" then
        table.insert(contents, { self.state, "Bubble" })
    elseif self.state == "SUCCESSFUL" then
        table.insert(contents, { self.state, "BitbucketPassingTest" })
    end

    return contents
end

return CommitStatus
