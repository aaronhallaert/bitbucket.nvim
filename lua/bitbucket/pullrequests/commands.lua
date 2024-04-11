local pr_api = require("bitbucket.pullrequests.api")
local pr_action = require("bitbucket.pullrequests.action")

---@param pull_requests PullRequest[]
local ui_select_pr = function(pull_requests)
    vim.ui.select(pull_requests, {
        format_item = function(entry)
            return entry.author .. ": " .. entry.title
        end,
    }, pr_action.select_pr_callback)
end

local M = {}

M.reviewing = function()
    pr_api.get_pull_requests_to_review(ui_select_pr)
end

M.mine = function()
    pr_api.get_my_pull_requests(ui_select_pr)
end

return M
