local PRCommentNode = require("bitbucket.entities.comments.pr_comment_node")
local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")

local M = {}

M.get_comments = function(pr, handle_comments)
    local url = string.format("/pullrequests/%d/comments", pr.id)
    url = url .. "?fields=values.*,values.resolution.*"

    Request:new({
        url = url,
        opts = { method = "GET", content_type = "application/json" },
        fn_parser = parse.parse_comments,
        fn_handler = function(comments)
            local root_comments = PRCommentNode.create_tree(comments)
            handle_comments(pr, root_comments)
        end,
    }):execute()
end

---@param pr PullRequest
---@param comment PRComment
M.resolve_comment_thread = function(pr, comment, handle_response)
    local url =
        string.format("/pullrequests/%d/comments/%d/resolve", pr.id, comment.id)

    Request:new({
        url = url,
        opts = { method = "POST" },
        fn_parser = function(_) end,
        fn_handler = handle_response,
    }):execute()
end

---@param pr PullRequest
---@param comment PRComment
M.reopen_comment_thread = function(pr, comment, handle_response)
    local url =
        string.format("/pullrequests/%d/comments/%d/resolve", pr.id, comment.id)

    Request:new({
        url = url,
        opts = { method = "DELETE" },
        fn_parser = function(_) end,
        fn_handler = handle_response,
    }):execute()
end

return M
