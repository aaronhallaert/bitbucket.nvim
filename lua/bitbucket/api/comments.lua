local PRCommentNode = require("bitbucket.entities.comments.pr_comment_node")
local Request = require("bitbucket.api.request")
local parse = require("bitbucket.api.parse")
local Logger = require("bitbucket.utils.logger")

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

---@param pr PullRequest
---@param handle_comments fun(pr: PullRequest, comments: PRCommentNode)
---@param page? number
---@param joined_comments? PRComment[]
M.get_comments = function(pr, handle_comments, page, joined_comments)
    local url = string.format("/pullrequests/%d/comments", pr.id)
    url = url .. "?fields=size,next,values.*,values.resolution.*"

    if page then
        url = url .. "&page=" .. page
    end

    ---@type PRComment[]
    local all_comments = joined_comments or {}

    Request
        :new({
            url = url,
            opts = { method = "GET", content_type = "application/json" },
            fn_parser = parse.parse_comments,
            ---@param comments PRCommentsResponse
            fn_handler = function(comments)
                for _, comment in ipairs(comments.values) do
                    table.insert(all_comments, comment)
                end

                Logger:log("#all_comments", #all_comments)
                Logger:log("#new_comments", #comments.values)
                if comments.next and comments.next ~= "" then
                    local next_page = comments.next:match(".*page=(%d*).*")
                    Logger:log("next_page", next_page)
                    require("bitbucket.api.comments").get_comments(
                        pr,
                        handle_comments,
                        next_page,
                        all_comments
                    )
                    return
                end

                local root_comments = PRCommentNode.create_tree(all_comments)
                handle_comments(pr, root_comments)
            end,
        })
        :execute()
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
