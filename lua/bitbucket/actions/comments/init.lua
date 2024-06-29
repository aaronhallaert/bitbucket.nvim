local async = require("plenary.async")
local Writer = require("bitbucket.ui.writer")
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
    function(buf, pr, comments, callback_fold)
        local folds = {}
        Writer:write(buf, pr:display())

        local inline_comments = vim.tbl_filter(function(item)
            return item:is_inline()
        end, comments)

        local general_comments = vim.tbl_filter(function(item)
            return item:is_general_comment()
        end, comments)

        Writer:write(buf, { "## Comments", "" })

        for _, comment in ipairs(general_comments) do
            wrapped_deserialize_comment(pr, nil, comment, 0, function(extra)
                Writer:write(buf, extra)
            end)
        end

        Writer:write(buf, { "", "", "## Review", "" })

        for _, comment in ipairs(inline_comments) do
            wrapped_deserialize_comment(pr, nil, comment, 0, function(extra)
                local startfold, endfold = Writer:write(buf, extra)
                table.insert(folds, { s = startfold, e = endfold })
            end)
        end

        callback_fold(folds)
    end,
    4
)

---@param pr PullRequest
---@param comments PRComment[]
M.display_comments = function(pr, comments)
    -- open a buffer and write the comments as json
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    generate_contents_from_comments(buf, pr, comments, function(folds)
        vim.print("showing the buffer")
        vim.api.nvim_command(":vsplit")

        vim.api.nvim_set_option_value("foldmethod", "manual", {})

        local winid = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(winid, buf)

        vim.api.nvim_buf_call(buf, function()
            for _, fold in ipairs(folds) do
                vim.api.nvim_command(
                    string.format("%d,%dfold", fold.s, fold.e - 1)
                )
            end
        end)
        vim.api.nvim_command("normal! zM")

        vim.api.nvim_command(":setlocal wrap")
    end)
end

return M
