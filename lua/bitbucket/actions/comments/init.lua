local M = {}

local PRCommentNode = require("bitbucket.actions.comments.pr_comment_node")

--- insert comment in table
---@param comment PRCommentNode
local function deserialize_comment(pr, contents, comment, indent)
    contents = contents or {}

    table.insert(contents, comment:display(pr, { indent = indent }))
    table.insert(contents, "")

    for _, child in ipairs(comment.children) do
        deserialize_comment(pr, contents, child, (indent or 0) + 1)
    end
end

---@param pr PullRequest
---@param comments PRComment[]
M.display_comments = function(pr, comments)
    -- open a buffer and write the comments as json
    local buf = vim.api.nvim_create_buf(false, true)

    local root_comments = PRCommentNode.create_tree(comments)
    local contents = {}

    table.insert(contents, pr:display())

    -- sort based on `inline` ~= nil
    local inline_comments = vim.tbl_filter(function(item)
        return item:is_inline()
    end, root_comments)

    local general_comments = vim.tbl_filter(function(item)
        return item:is_general_comment()
    end, root_comments)

    table.insert(contents, "## Comments")
    table.insert(contents, "")

    for _, comment in ipairs(general_comments) do
        deserialize_comment(pr, contents, comment, 0)
    end

    table.insert(contents, "")
    table.insert(contents, "")
    table.insert(contents, "## Review")
    table.insert(contents, "")

    for _, comment in ipairs(inline_comments) do
        deserialize_comment(pr, contents, comment, 0)
    end

    -- set filetype to markdown
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_flatten(contents))

    -- split a window but more basic than the example code above, just a split right
    vim.api.nvim_command(":vsplit")
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winid, buf)
    vim.api.nvim_command(":setlocal wrap")
end

return M
