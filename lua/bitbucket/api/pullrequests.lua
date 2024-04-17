local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")
local Env = require("bitbucket.utils.env")

local M = {}

---@param query string
---@param handle_pullrequests fun(prs: PullRequest[])
M.get_pull_requests = function(query, handle_pullrequests)
    local url = "/pullrequests?q="
        .. require("bitbucket.utils").url_encode(query)

    Request:new({
        url = url,
        opts = { method = "GET", content_type = "application/json" },
        fn_parser = parse.parse_pullrequests,
        fn_handler = handle_pullrequests,
    }):execute()
end

M.get_pull_requests_to_review = function(callback)
    local query = string.format(
        'state="%s" AND reviewers.username="%s"',
        "open",
        Env.user.username
    )
    return M.get_pull_requests(query, callback)
end

M.get_my_pull_requests = function(callback)
    local query = string.format(
        'state="%s" AND author.username="%s"',
        "open",
        Env.user.username
    )

    return M.get_pull_requests(query, callback)
end

return M
