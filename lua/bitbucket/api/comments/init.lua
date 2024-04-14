local api = require("bitbucket.api")
local pr_api = require("bitbucket.api.pullrequests")
local parse = require("bitbucket.api.parse")

local M = {}

M.get_comments = function(pr, handle_comments)
    local workspace, repo = require("bitbucket.utils.git").repo()
    if workspace == nil or repo == nil then
        vim.print("No workspace or repo found")
        return {}
    end

    local url =
        string.format("%s/%d/comments", pr_api.base_url(workspace, repo), pr.id)

    api.execute_request(
        url,
        { method = "GET", content_type = "application/json" },
        function(response)
            handle_comments(pr, parse.parse_comments(response))
        end
    )
end
return M
