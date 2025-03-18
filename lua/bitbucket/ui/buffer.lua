local navigation = require("bitbucket.ui.navigation")
local signs = require("bitbucket.ui.signs")
local ns = require("bitbucket.utils.ns")
local Writer = require("bitbucket.ui.writer")
local CommitStatus = require("bitbucket.entities.commit_status")
local Activity = require("bitbucket.entities.activity")
local Logger = require("bitbucket.utils.logger")
local temp = require("bitbucket.actions.comments")
local help = require("bitbucket.ui.help")

---@class Buffer
---@field buf_id number
---@field pr PullRequest
---@field comments PRCommentNode[]
---@field activity Activity
---@field statuses CommitStatus[]
---@field threads ThreadMeta[]
local Buffer = {}

Buffer.__index = Buffer

function Buffer:reload_callback()
    return function()
        self:reload()
    end
end

function Buffer:line_count()
    return vim.api.nvim_buf_line_count(self.buf_id)
end

---@return Buffer
function Buffer:new(o)
    local obj = vim.tbl_extend("keep", o or {}, { threads = {} })

    -- create keymap only for filetype bitbucket_ft
    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "gf", "", {
        callback = function()
            navigation.goto_file(obj.buf_id)
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "g?", "", {
        callback = function()
            help.open()
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "go", "", {
        callback = function()
            obj.pr:browse()
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "gc", "", {
        callback = function()
            obj.pr:checkout()
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "gd", "", {
        callback = function()
            require("bitbucket.actions.pullrequests").open_diff(obj.pr)
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "<leader>rt", "", {
        callback = function()
            require("bitbucket.ui.interactions").resolve_thread(obj.buf_id)
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "<leader>ot", "", {
        callback = function()
            require("bitbucket.ui.interactions").reopen_thread(obj.buf_id)
        end,
    })

    return setmetatable(obj, self)
end

function Buffer:show()
    vim.api.nvim_set_option_value(
        "filetype",
        "bitbucket_ft",
        { buf = self.buf_id }
    )

    vim.api.nvim_buf_set_keymap(
        self.buf_id,
        "n",
        "<Tab>",
        ":normal! zjzMzozt<CR>",
        { noremap = true, silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        self.buf_id,
        "n",
        "<S-Tab>",
        ":normal! zkkzMzozt<CR>",
        { noremap = true, silent = true }
    )

    local folds = self:write()

    if self.buf_id ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_command(":vsplit")

        local winid = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(winid, self.buf_id)
    end

    vim.api.nvim_set_option_value("foldmethod", "manual", {})

    vim.api.nvim_buf_call(self.buf_id, function()
        for _, fold in ipairs(folds) do
            vim.api.nvim_command(string.format("%d,%dfold", fold.s, fold.e - 1))
        end
    end)
    vim.api.nvim_command("normal! zM")

    vim.api.nvim_command(":setlocal wrap")
    vim.api.nvim_command(":setlocal linebreak")
    vim.api.nvim_command(":setlocal breakindent")
end

function Buffer:reload()
    require("bitbucket.api.comments").get_comments(
        self.pr,
        function(pr_1, comments)
            require("bitbucket.api.activity").get_activity(
                pr_1,
                function(pr, activity)
                    require("bitbucket.api.statuses").get_statuses(
                        pr,
                        function(_, statuses)
                            self.comments = comments
                            self.activity = activity
                            self.statuses = statuses

                            local current_line =
                                vim.api.nvim_win_get_cursor(0)[1]
                            self:clear()
                            self:show()
                            vim.api.nvim_win_set_cursor(0, { current_line, 0 })
                            vim.api.nvim_command("normal! zR")
                        end
                    )
                end
            )
        end
    )
end

function Buffer:clear()
    vim.api.nvim_buf_clear_namespace(self.buf_id, -1, 0, -1)
    vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, {})
end

function Buffer:write()
    local buf = self.buf_id
    local folds = {}
    Writer:write(buf, self.pr:display())

    local inline_comments = vim.tbl_filter(function(item)
        return item:is_inline()
    end, self.comments)

    local general_comments = vim.tbl_filter(
        ---@param item PRCommentNode
        function(item)
            return item:is_general_comment()
        end,
        self.comments
    )

    if next(self.statuses) ~= nil then
        Logger:log(self.statuses)
        for _, status in ipairs(self.statuses) do
            local stat = CommitStatus:new(status)
            Writer:write(buf, stat:display())
        end
        Writer:write(buf, { { "" } })
    end

    local act = Activity:new(self.activity)
    if act.events ~= {} then
        Writer:write(buf, act:display())
        Writer:write(buf, { { "" } })
    end

    for _, comment in ipairs(general_comments) do
        local deserialized_comment =
            temp.deserialize_comment(self.pr, nil, comment, 0)
        -- local c = self:line_count()
        local s, e = Writer:write(buf, deserialized_comment.contents)
        -- local loc = deserialized_comment.comment_location
        -- Logger:log("Final contents length", #deserialized_comment.contents)
        -- Logger:log("Final deserialized location", loc)
        signs.place_comment_sign(buf, s, e - 1)
    end

    Writer:write(buf, { { "## Review", "Title" } })

    for _, comment in ipairs(inline_comments) do
        local deserialized_comment =
            temp.deserialize_comment(self.pr, nil, comment, 0)

        local startfold, endfold =
            Writer:write(buf, deserialized_comment.contents)

        table.insert(folds, { s = startfold, e = endfold })

        self:add_thread({
            mark_id = -1,
            start_line_mark = startfold - 1,
            end_line_mark = endfold,
            line = comment.inline.from or comment.inline.to or 0,
            path = comment.inline.path,
            comment = comment,
        })

        local loc = deserialized_comment.comment_location

        signs.place_comment_sign(
            buf,
            startfold + loc.start_line + 1,
            startfold + loc.end_line + 1
        )
    end
    return folds
end

---@param thread ThreadMeta
function Buffer:add_thread(thread)
    local mark_id = vim.api.nvim_buf_set_extmark(
        self.buf_id,
        ns.thread,
        thread.start_line_mark - 1,
        0,
        {
            end_row = thread.end_line_mark,
        }
    )

    thread.mark_id = mark_id

    table.insert(self.threads, thread)
end

---@param mark_id number
---@return ThreadMeta|nil
function Buffer:get_thread_by_mark_id(mark_id)
    for _, thread in ipairs(self.threads) do
        if thread.mark_id == mark_id then
            return thread
        end
    end
end

return Buffer
