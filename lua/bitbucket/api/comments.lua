local PRCommentNode = require("bitbucket.entities.comments.pr_comment_node")
local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")

local M = {}

---@param pr PullRequest
---@param loc PRCommentLocation|nil
---@param anchor string hash
---@param dest_rev string hash
---@param content string
---@param pending boolean
---@param handle_comment fun(comment: PRComment)
M.create_comment = function(
    pr,
    loc,
    anchor,
    dest_rev,
    content,
    pending,
    handle_comment
)
    local url = string.format("/pullrequests/%d/comments", pr.id)

    local body = {
        content = { raw = content },
        anchor = anchor,
        dest_rev = dest_rev,
        pending = pending,
    }

    if loc then
        body.inline = {
            path = loc.path,
            to = loc.to,
        }
    end

    Request:new({
        url = url,
        opts = {
            method = "POST",
            content_type = "application/json",
            body = body,
        },
        fn_parser = parse.parse_comment,
        fn_handler = function(comment)
            handle_comment(comment)
        end,
    }):execute()
end

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
