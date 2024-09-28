local M = {}

---@param buf_id number
M.goto_file = function(buf_id)
    local thread = require("bitbucket.ui").get_current_thread(buf_id)
    if thread == nil then
        return
    end

    -- open file in new buffer on line
    vim.cmd("e " .. thread.path)
    vim.api.nvim_win_set_cursor(0, { thread.line, 0 })
end
return M
