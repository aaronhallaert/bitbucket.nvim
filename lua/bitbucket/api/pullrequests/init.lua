local api = require("bitbucket.api")
local parse = require("bitbucket.api.parse")

---@param workspace string
---@param repo string
local base_url = function(workspace, repo)
    return "https://api.bitbucket.org/2.0/repositories/"
        .. workspace
        .. "/"
        .. repo
        .. "/pullrequests"
end

local M = {}

M.base_url = base_url

---@param query string
---@param handle_pull_requests function(PullRequest[]): void
M.get_pull_requests = function(query, handle_pull_requests)
    local workspace, repo = require("bitbucket.utils.git").repo()
    if workspace == nil or repo == nil then
        vim.print("No workspace or repo found")
        return {}
    end

    local url = base_url(workspace, repo)
        .. "?q="
        .. require("bitbucket.utils").url_encode(query)

    api.execute_request(
        url,
        { method = "GET", content_type = "application/json" },
        function(response)
            local pull_requests = parse.parse_pull_requests_response(response)
            handle_pull_requests(pull_requests)
        end
    )
end

M.get_pull_requests_to_review = function(callback)
    local query = string.format(
        'state="%s" AND reviewers.username="%s"',
        "open",
        api.current_user
    )
    return M.get_pull_requests(query, callback)
end

M.get_my_pull_requests = function(callback)
    local query = string.format(
        'state="%s" AND author.username="%s"',
        "open",
        api.current_user
    )

    return M.get_pull_requests(query, callback)
end

return M
