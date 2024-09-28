local ns = require("bitbucket.utils.ns")
local M = {}

---@param buf_id number
M.get_current_thread = function(buf_id)
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
    for _, mark in ipairs(thread_marks) do
        local thread = buffer:get_thread_by_mark_id(mark[1])
        if thread == nil then
            goto continue
        end

        if
            current_line >= thread.start_line_mark
            and current_line <= thread.end_line_mark
        then
            return thread
        end
        ::continue::
    end
end

return M
