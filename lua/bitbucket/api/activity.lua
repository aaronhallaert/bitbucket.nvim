local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")

local M = {}

---@param pr PullRequest
---@param handle_activity fun(pr: PullRequest, activity: Activity)
M.get_activity = function(pr, handle_activity)
    local url = string.format("/pullrequests/%d/activity", pr.id)

    Request:new({
        url = url,
        opts = { method = "GET", content_type = "application/json" },
        fn_parser = parse.parse_comments,
        fn_handler = function(activity)
            handle_activity(pr, activity)
        end,
    }):execute()
end

return M
