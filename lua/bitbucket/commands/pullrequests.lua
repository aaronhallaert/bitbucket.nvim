local pr_api = require("bitbucket.api.pullrequests")
local BitbucketState = require("bitbucket.state")
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

---@param loc PRCommentLocation
local function create_comment(loc)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    -- Get the current window dimensions
    local width = vim.api.nvim_get_option_value("columns", {})
    local height = vim.api.nvim_get_option_value("lines", {})

    -- Calculate the floating window size and position
    local win_width = math.ceil(width * 0.5)
    local win_height = 10
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
    })
    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "q",
        ":q<CR>",
        { noremap = true, silent = true }
    )

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
    -- Create a namespace for the virtual text
    local ns_id = vim.api.nvim_create_namespace("bitbucket_virtual_text")

    -- Function to set the virtual text at the last line of the buffer
    local function set_virtual_text(bfr)
        -- first clear the existing virtual text
        vim.api.nvim_buf_clear_namespace(bfr, ns_id, 0, -1)
        local last_line = vim.api.nvim_buf_line_count(bfr) - 1
        -- also add an empty line at the end
        vim.api.nvim_buf_set_extmark(bfr, ns_id, last_line, 0, {
            virt_text = {
                { "<q> to confirm", "Comment" },
            },
            virt_text_pos = "eol",
        })
    end

    -- Set the initial virtual text
    set_virtual_text(buf)

    -- Create an autocommand to update the virtual text on buffer changes
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = buf,
        callback = function()
            set_virtual_text(buf)
        end,
    })

    -- Create an autocommand to capture input on WinLeave
    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = buf,
        callback = function()
            local captured_input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            -- remove the last empty line
            if captured_input[#captured_input] == "" then
                table.remove(captured_input)
            end

            vim.api.nvim_buf_delete(buf, { force = true })

            comments_api.create_comment(
                BitbucketState.selected.pr,
                loc,
                BitbucketState.selected.pr.source.commit.hash,
                BitbucketState.selected.pr.destination.commit.hash,
                table.concat(captured_input, "\n"),
                true,
                function(response)
                    Logger:log("Comment created", response)
                end
            )
        end,
    })
end

M.comment = function()
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
    create_comment(loc)
end

M.query = function(query)
    pr_api.get_pull_requests(query, ui_select_pr)
end

return M
