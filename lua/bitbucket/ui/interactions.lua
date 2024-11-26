local api = require("bitbucket.api.comments")

local M = {}

---@param buf_id number
M.reply_comment = function(buf_id)
    local thread = require("bitbucket.ui").get_current_thread(buf_id)
    if thread == nil then
        return
    end

    vim.print(thread.comment.id)
end

---@param buf_id number
M.resolve_thread = function(buf_id)
    local buffer = require("bitbucket.state"):get_buffer(buf_id)
    if buffer == nil then
        return
    end

    local thread = require("bitbucket.ui").get_current_thread(buf_id)
    if thread == nil then
        return
    end

    api.resolve_comment_thread(
        buffer.pr,
        thread.comment,
        buffer:reload_callback()
    )
end

---@param buf_id number
M.reopen_thread = function(buf_id)
    local buffer = require("bitbucket.state"):get_buffer(buf_id)
    if buffer == nil then
        return
    end

    local thread = require("bitbucket.ui").get_current_thread(buf_id)
    if thread == nil then
        return
    end

    api.reopen_comment_thread(
        buffer.pr,
        thread.comment,
        buffer:reload_callback()
    )
end

return M
