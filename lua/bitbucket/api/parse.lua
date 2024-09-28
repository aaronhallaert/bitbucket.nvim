local PullRequest = require("bitbucket.entities.pullrequest")
local Logger = require("bitbucket.utils.logger")
local M = {}

---@param response_body table
---@return PullRequest[]
M.parse_pullrequests = function(response_body)
    ---@type PullRequest[]
    local pull_requests = {}

    for _, pr_resp in ipairs(response_body.values) do
        ---@type PullRequest
        local pull_request = PullRequest:new(pr_resp)
        table.insert(pull_requests, pull_request)
    end

    return pull_requests
end

---@param response_body table
---@return PRComment[]
M.parse_comments = function(response_body)
    ---@type PRComment[]
    return response_body.values
end
---
---@param response_body table
---@return Activity[]
M.parse_activities = function(response_body)
    ---@type Activity[]
    return response_body.values
end

---@param response_body table
---@return CommitStatus[]
M.parse_statuses = function(response_body)
    ---@type CommitStatus[]
    return response_body.values
end

return M
