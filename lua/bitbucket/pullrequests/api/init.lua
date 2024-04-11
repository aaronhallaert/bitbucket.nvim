local Job = require("plenary.job")
require("bitbucket.pullrequests.types")

local parse = require("bitbucket.pullrequests.api.parse")

local url_encode = function(str)
    if type(str) ~= "number" then
        str = str:gsub("\r?\n", "\r\n")
        str = str:gsub("([^%w%-%.%_%~ ])", function(c)
            return string.format("%%%02X", c:byte())
        end)
        str = str:gsub(" ", "+")
        return str
    else
        return str
    end
end

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
---@param callback function(PullRequest[])
local get_pull_requests = function(query, callback)
    local workspace, repo = require("bitbucket.utils.git").repo()
    if workspace == nil or repo == nil then
        vim.print("No workspace or repo found")
        return {}
    end

    local url = base_url(workspace, repo) .. "?q=" .. url_encode(query)

    Job:new({
        command = "curl",
        args = {
            "-X",
            "GET",
            "-H",
            "Content-Type: application/json",
            "-u",
            username .. ":" .. password,
            url,
        },
        on_exit = function(j, return_val)
            if return_val ~= 0 then
                vim.print("Failed to get pull requests")
                callback({})
                return
            end

            local result = j:result()
            vim.schedule(function()
                local response = vim.fn.json_decode(result)
                callback(parse.parse_pull_requests_response(response))
            end)
        end,
    }):start()
end

M.get_pull_requests_to_review = function(callback)
    local query = string.format(
        'state="%s" AND reviewers.username="%s"',
        "open",
        username
    )
    return get_pull_requests(query, callback)
end

M.get_my_pull_requests = function(callback)
    local query =
        string.format('state="%s" AND author.username="%s"', "open", username)
    return get_pull_requests(query, callback)
end

return M
