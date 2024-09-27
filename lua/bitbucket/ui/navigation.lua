local ns = require("bitbucket.utils.ns")
local M = {}

---@param buf_id number
M.goto_file = function(buf_id)
    local buffer = require("bitbucket.state"):get_buffer(buf_id)
    if buffer == nil then
        return
    end

    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    -- get mark at current line of namespace ns.threads
    local thread_marks = vim.api.nvim_buf_get_extmarks(
        buf_id,
        ns.thread,
        0,
        -1,
        { details = true }
    )

    ---@type ThreadMeta|nil
    local thread = nil
    for _, mark in ipairs(thread_marks) do
        local temp_thread = buffer:get_thread_by_mark_id(mark[1])
        if temp_thread == nil then
            goto continue
        end

        if
            current_line >= temp_thread.start_line_mark
            and current_line <= temp_thread.end_line_mark
        then
            thread = temp_thread
            goto found
        end
        ::continue::
    end
    ::found::

    if thread == nil then
        return
    end
    -- open file in new buffer on line
    vim.cmd("e " .. thread.path)
    vim.api.nvim_win_set_cursor(0, { thread.line, 0 })
end
return M
