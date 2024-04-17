local async = require("plenary.async")
local M = {}

--- insert comment in table
---@param comment PRCommentNode
local function deserialize_comment(pr, contents, comment, indent)
    contents = contents or {}

    table.insert(contents, comment:display(pr, { indent = indent }))
    table.insert(contents, "")

    for _, child in ipairs(comment.children) do
        deserialize_comment(pr, contents, child, (indent or 0) + 1)
    end

    return contents
end

local wrapped_deserialize_comment = async.wrap(
    function(pr, contents, comment, indent, callback)
        vim.print("wrapped")
        local ret = deserialize_comment(pr, contents, comment, indent)
        callback(ret)
    end,
    5
)

local generate_contents_from_comments = async.wrap(
    function(pr, comments, callback)
        local contents = {}

        table.insert(contents, pr:display())

        local inline_comments = vim.tbl_filter(function(item)
            return item:is_inline()
        end, comments)

        local general_comments = vim.tbl_filter(function(item)
            return item:is_general_comment()
        end, comments)

        table.insert(contents, "## Comments")
        table.insert(contents, "")

        for _, comment in ipairs(general_comments) do
            wrapped_deserialize_comment(pr, nil, comment, 0, function(extra)
                table.insert(contents, extra)
            end)
        end

        table.insert(contents, "")
        table.insert(contents, "")
        table.insert(contents, "## Review")
        table.insert(contents, "")

        for _, comment in ipairs(inline_comments) do
            wrapped_deserialize_comment(pr, nil, comment, 0, function(extra)
                table.insert(contents, extra)
            end)
        end

        callback(contents)
    end,
    3
)

---@param pr PullRequest
---@param comments PRComment[]
M.display_comments = function(pr, comments)
    -- open a buffer and write the comments as json
    local buf = vim.api.nvim_create_buf(false, true)

    generate_contents_from_comments(pr, comments, function(contents)
        vim.print("setting the buffer")
        -- set filetype to markdown
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_flatten(contents))
        vim.print("setting the buffer, done")
    end)

    vim.print("showing the buffer")
    -- split a window but more basic than the example code above, just a split right
    vim.api.nvim_command(":vsplit")
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winid, buf)
    vim.api.nvim_command(":setlocal wrap")
    --
    vim.print("jipla display comments done")
end

return M
