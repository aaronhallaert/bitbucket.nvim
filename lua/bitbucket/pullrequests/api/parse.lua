local M = {}

---@param response_body table
---@return PullRequest[]
M.parse_pull_requests_response = function(response_body)
    ---@type PullRequest[]
    local pull_requests = {}

    for _, pr_resp in ipairs(response_body.values) do
        -- vim.print(pr_resp["author"])

        ---@type PullRequest
        local pull_request = {
            id = pr_resp["id"],
            links = pr_resp["links"],
            title = pr_resp["title"],
            summary = pr_resp["summary"]["html"],
            author = pr_resp["author"]["display_name"],
            source = {
                branch = pr_resp["source"]["branch"],
                commit = pr_resp["source"]["commit"],
            },
            destination = {
                branch = pr_resp["destination"]["branch"],
                commit = pr_resp["destination"]["commit"],
            },
        }

        table.insert(pull_requests, pull_request)
    end

    return pull_requests
end

return M
