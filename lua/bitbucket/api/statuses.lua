local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")

local M = {}

---@param pr PullRequest
---@param handle_statuses fun(pr: PullRequest, statuses: CommitStatus[])
M.get_statuses = function(pr, handle_statuses)
    local url = string.format("/pullrequests/%d/statuses", pr.id)

    Request:new({
        url = url,
        opts = { method = "GET", content_type = "application/json" },
        fn_parser = parse.parse_statuses,
        fn_handler = function(statuses)
            handle_statuses(pr, statuses)
        end,
    }):execute()
end

return M
