local async = require("plenary.async")
local M = {}

--- insert comment in table
---@param comment PRCommentNode
local function deserialize_comment(pr, contents, comment, indent)
    contents = contents or {}

    for _, c_line in ipairs(comment:display(pr, { indent = indent })) do
        table.insert(contents, c_line)
    end
    table.insert(contents, "")

    for _, child in ipairs(comment.children) do
        deserialize_comment(pr, contents, child, (indent or 0) + 1)
    end

    return contents
end

M.wrapped_deserialize_comment = async.wrap(
    ---@param pr PullRequest
    ---@param comment PRCommentNode
    function(pr, contents, comment, indent, callback)
        local ret = deserialize_comment(pr, contents, comment, indent)
        callback(ret)
    end,
    5
)

return M
