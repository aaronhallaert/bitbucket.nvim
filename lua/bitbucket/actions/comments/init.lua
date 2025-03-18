local Logger = require("bitbucket.utils.logger")
local M = {}

---@class DeserializedComment
---@field contents table
---@field comment_location CommentLocation

--- insert comment in table
---@param pr PullRequest
---@param comment PRCommentNode
---@return DeserializedComment
M.deserialize_comment = function(pr, contents, comment, indent)
    contents = contents or {}

    ---@type CommentLocation
    local comment_location = {
        start_line = 0,
        end_line = 0,
    }

    local comment_display = comment:display(pr, { indent = indent })
    if comment_display.comment_location then
        comment_location = {
            start_line = comment_display.comment_location.start_line
                + #contents,
            end_line = comment_display.comment_location.end_line + #contents,
        }
    end

    for _, c_line in ipairs(comment_display.contents) do
        table.insert(contents, c_line)
    end
    table.insert(contents, "")

    for _, child in ipairs(comment.children) do
        local inner_return =
            M.deserialize_comment(pr, contents, child, (indent or 0) + 1)
        comment_location.end_line = inner_return.comment_location.end_line
    end

    return { contents = contents, comment_location = comment_location }
end

return M
