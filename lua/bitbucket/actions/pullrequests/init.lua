local Git = require("bitbucket.utils.git")
local bb_ns = require("bitbucket.utils.ns")
local Buffer = require("bitbucket.ui.buffer")
local BitbucketState = require("bitbucket.state")

---@param pr PullRequest
---@param comments PRComment[]
---@param activity Activity[]
---@param statuses CommitStatus[]
local buf_factory = function(pr, comments, activity, statuses)
    local buf = vim.api.nvim_create_buf(false, true)
    local buffer = Buffer:new({
        buf_id = buf,
        pr = pr,
        comments = comments,
        activity = activity,
        statuses = statuses,
    })
    BitbucketState:set_selected(pr, buffer)
    BitbucketState:add_buffer(buffer)
    buffer:show()
end

---@param item PullRequest
local open_in_buf = function(item)
    require("bitbucket.api.comments").get_comments(
        item,
        function(pr_1, comments)
            require("bitbucket.api.activity").get_activity(
                pr_1,
                function(pr, activity)
                    require("bitbucket.api.statuses").get_statuses(
                        pr,
                        function(_, statuses)
                            buf_factory(pr, comments, activity, statuses)
                        end
                    )
                end
            )
        end
    )
end

local M = {}

---@param item PullRequest
---@param _ any
M.select_pr_callback = function(item, _)
    if item == nil then
        return
    end
    open_in_buf(item)
end

---@param pr PullRequest
---@param buffer Buffer
local apply_comments = function(pr, buffer)
    -- key: buffer, value: comments
    local buf_comments = {}
    -- diffview:///home/aaron/Developer/televic/plixus-apps/.git/478ae538516/apps/core/src/core_main/src/core.cpp
    for _, comment in ipairs(buffer.comments) do
        if comment:is_inline() then
            -- construct the target buffer name to place a symbol in
            local buffer = "diffview://"
                -- pwd
                .. os.getenv("PWD")
                .. "/.git/"
                -- cut the hash to 11 characters
                .. string.sub(pr.source.commit.hash, 1, 11)
                .. "/"
                .. comment.inline.path

            vim.print(buffer)
            -- find buffer by name
            buf_comments[buffer] = buf_comments[buffer] or {}
            table.insert(buf_comments[buffer], comment)
        end
    end

    local write_comments_in_diff
    write_comments_in_diff = function(comments, bufnr, indent)
        indent = indent or 0
        local prefix = string.rep("\t", indent) or ""
        for _, comment in ipairs(comments) do
            ---@cast comment PRCommentNode

            local text = {}
            table.insert(text, prefix .. "  " .. comment.user.display_name)
            for _, line in ipairs(comment:_parse_content()) do
                table.insert(text, prefix .. line[1])
            end

            table.insert(text, "")

            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, text)

            write_comments_in_diff(comment.children, bufnr, indent + 1)
        end
    end

    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup(
            "BitbucketComments",
            { clear = true }
        ),
        pattern = "diffview://*",
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local buf_name = vim.api.nvim_buf_get_name(bufnr)
            local comments = buf_comments[buf_name]

            if comments == nil then
                return
            end

            for _, comment in ipairs(comments) do
                local line = comment.inline.to
                vim.print(line)
                vim.fn.sign_define(
                    "comment_sign",
                    { text = "🗨️", texthl = "Comment" }
                )
                vim.fn.sign_place(
                    0,
                    "comment_group",
                    "comment_sign",
                    bufnr,
                    { lnum = line - 1, priority = 10 }
                )
            end

            -- when H is pressed in the diffview window
            vim.api.nvim_buf_set_keymap(bufnr, "n", "H", "", {
                callback = function()
                    for _, comment in ipairs(comments) do
                        local line = comment.inline.to - 1
                        vim.print(line)
                        local current_line = vim.api.nvim_win_get_cursor(0)[1]
                        if line == current_line then
                            local comment_bufnr =
                                vim.api.nvim_create_buf(false, true)
                            write_comments_in_diff({ comment }, comment_bufnr)
                            -- Create a floating window to display the comments
                            local width = math.max(
                                40,
                                math.min(80, vim.fn.winwidth(0) - 10)
                            )
                            local height = math.min(10, 10)
                            local opts = {
                                relative = "editor",
                                width = width,
                                height = height,
                                row = math.floor((vim.o.lines - height) / 2),
                                col = math.floor((vim.o.columns - width) / 2),
                                style = "minimal",
                                border = "rounded",
                            }

                            local win_id =
                                vim.api.nvim_open_win(comment_bufnr, true, opts)

                            -- Optionally, set buffer options for better UX
                            vim.bo[comment_bufnr].filetype = "markdown"
                            vim.bo[comment_bufnr].bufhidden = "wipe"
                            vim.bo[comment_bufnr].modifiable = false
                            vim.wo[win_id].wrap = true
                            vim.bo[comment_bufnr].textwidth = 80
                        end
                    end
                end,
            })
        end,
    })
end

---@param item PullRequest
---@param buffer Buffer
M.open_diff = function(item, buffer)
    Git:new({
        callback = function(_)
            -- execute DiffviewOpen
            local source_hash = item.source.commit.hash
            local destination_hash = item.destination.commit.hash

            Git:new({
                callback = function(merge_base_hash)
                    vim.api.nvim_command(
                        ":DiffviewOpen -uno "
                            .. merge_base_hash[1]
                            .. ".."
                            .. source_hash
                    )
                end,
            }):merge_base(source_hash, destination_hash)
            apply_comments(item, buffer)
        end,
    }):fetch_all()
end

return M
