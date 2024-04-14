local PullRequest = require("bitbucket.types.pullrequest")
local M = {}

---@param response_body table
---@return PullRequest[]
M.parse_pull_requests_response = function(response_body)
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

return M
