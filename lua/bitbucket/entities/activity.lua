local Logger = require("bitbucket.utils.logger")
local utils = require("bitbucket.utils")
---@class ApprovalUser
---@field display_name string

---@class Approval
---@field user ApprovalUser
---@field date string
local Approval = {}
Approval.__index = Approval

---@class Event
---@field type string
---@field data Approval

---@class Activity
---@field events Event[]
local Activity = {}

Activity.__index = Activity

---@param o Approval
---@return Approval
function Approval:new(o)
    local obj = o
    return setmetatable(obj, self)
end

---@param o table
---@return Activity
function Activity:new(o)
    ---@type Activity
    local obj = {
        events = {},
    }

    for _, tab in ipairs(o) do
        for k, v in pairs(tab) do
            if k == "approval" then
                ---@type Event
                local approv = {
                    type = "approval",
                    data = Approval:new(v),
                }

                table.insert(obj.events, approv)
            end
        end
    end

    return setmetatable(obj, self)
end

function Activity:display()
    local content = {}
    for _, event in ipairs(self.events) do
        -- check if type is Approval
        if event.type == "approval" then
            ---@type Approval
            local approval = event.data

            table.insert(content, {
                "APPROVED by "
                    .. approval.user.display_name
                    .. " ("
                    .. utils.time_difference(approval.date)
                    .. ")",
                "BitbucketStateApprovedBubble",
            })
        end
    end

    return content
end

return Activity
