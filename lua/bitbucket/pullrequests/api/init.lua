require("bitbucket.pullrequests.types")

local curl = require("plenary.curl")
local parse = require("bitbucket.pullrequests.api.parse")

local config = require("bitbucket.utils.config")
local username, password = config.user_data()

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

---@param query string
---@return PullRequest[]
local get_pull_requests = function(query)
    local workspace, repo = require("bitbucket.utils.git").repo()
    if workspace == nil or repo == nil then
        vim.print("No workspace or repo found")
        return {}
    end

    local url = base_url(workspace, repo)

    local response = curl.get({
        method = "GET",
        url = url,
        query = {
            ["q"] = query,
        },
        auth = username .. ":" .. password,
    })

    if response.status ~= 200 then
        vim.print("Failed to get pull requests")
        return {}
    end

    return parse.parse_pull_requests_response(
        vim.json.decode(response.body, { object = true })
    )
end

M.get_pull_requests_to_review = function()
    local query = string.format(
        'state="%s" AND reviewers.username="%s"',
        "open",
        username
    )
    return get_pull_requests(query)
end

M.get_my_pull_requests = function()
    local query =
        string.format('state="%s" AND author.username="%s"', "open", username)
    return get_pull_requests(query)
end

return M
