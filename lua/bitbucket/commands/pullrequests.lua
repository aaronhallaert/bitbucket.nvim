local pr_api = require("bitbucket.api.pullrequests")
local comments_api = require("bitbucket.api.comments")
local pr_action = require("bitbucket.actions.pullrequests")
local Logger = require("bitbucket.utils.logger")

---@param pull_requests PullRequest[]
local ui_select_pr = function(pull_requests)
    vim.ui.select(pull_requests, {
        ---@param entry PullRequest
        format_item = function(entry)
            return entry.author.display_name .. ": " .. entry.title
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

M.approve = function()
    local BitbucketState = require("bitbucket.state")
    if BitbucketState.selected == nil then
        vim.notify("No PR selected", vim.log.levels.ERROR)
        return
    end

    pr_api.approve(BitbucketState.selected.pr, function(response)
        Logger:log("Approved PR", response)
        BitbucketState.selected.buffer:reload()
        vim.notify("Approved PR", vim.log.levels.INFO)
    end)
end

M.comment = function()
    local BitbucketState = require("bitbucket.state")
    if BitbucketState.selected == nil then
        vim.notify("No PR selected", vim.log.levels.ERROR)
        return
    end

    local current_file_path = nil
    if require("diffview") then
        local view = require("diffview.lib").get_current_view()

        local lazy = require("diffview.lazy")
        local DiffView =
            lazy.access("diffview.scene.views.diff.diff_view", "DiffView") ---@type DiffView|LazyModule
        if view and (view:instanceof(DiffView.__get())) then
            current_file_path =
                require("bitbucket.utils.file").abs_path_to_git_relative_path(
                    require("diffview.lib").get_current_view().cur_entry.absolute_path
                )
        else
            current_file_path =
                require("bitbucket.utils.file").git_relative_path(
                    vim.fn.bufnr()
                )
        end
    else
        current_file_path =
            require("bitbucket.utils.file").git_relative_path(vim.fn.bufnr())
    end

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    ---@type PRCommentLocation
    local loc = {
        path = current_file_path,
        to = current_line,
    }

    -- ask input
    local content = vim.fn.input("Comment: ")

    comments_api.create_comment(
        BitbucketState.selected.pr,
        loc,
        BitbucketState.selected.pr.source.commit.hash,
        BitbucketState.selected.pr.destination.commit.hash,
        content,
        true,
        function(response)
            Logger:log("Comment created", response)
        end
    )
end

M.query = function(query)
    pr_api.get_pull_requests(query, ui_select_pr)
end

return M
