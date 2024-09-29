local async = require("plenary.async")
local Logger = require("bitbucket.utils.logger")
local M = {}

---@class DeserializedComment
---@field contents table
---@field comment_locations CommentLocation[]

--- insert comment in table
---@param comment PRCommentNode
---@return DeserializedComment
local function deserialize_comment(pr, contents, comment, indent)
    contents = contents or {}

    ---@type CommentLocation[]
    local comment_locations = {}

    local comment_display = comment:display(pr, { indent = indent })
    if comment_display.comment_location then
        table.insert(comment_locations, {
            start_line = comment_display.comment_location.start_line
                + #contents
                + 1,
            end_line = comment_display.comment_location.end_line
                + #contents
                + 1,
        })
    end

    for _, c_line in ipairs(comment_display.contents) do
        table.insert(contents, c_line)
    end
    table.insert(contents, "")

    for _, child in ipairs(comment.children) do
        deserialize_comment(pr, contents, child, (indent or 0) + 1)
    end

    return { contents = contents, comment_locations = comment_locations }
end

M.wrapped_deserialize_comment = async.wrap(
    ---@param pr PullRequest
    ---@param comment PRCommentNode
    ---@param callback fun(DeserializedComment)
    function(pr, contents, comment, indent, callback)
        local ret = deserialize_comment(pr, contents, comment, indent)
        callback(ret)
    end,
    5
)

return M
