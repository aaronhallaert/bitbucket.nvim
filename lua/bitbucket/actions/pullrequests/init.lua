local Git = require("bitbucket.utils.git")
local Buffer = require("bitbucket.ui.buffer")
local BitbucketState = require("bitbucket.state")

---@param pr PullRequest
---@param comments PRComment[]
---@param activity Activity[]
---@param statuses CommitStatus[]
local buf_factory = function(pr, comments, activity, statuses)
    local buf = vim.api.nvim_create_buf(false, true)
    local buffer = Buffer:new({
        buf_id = buf,
        pr = pr,
        comments = comments,
        activity = activity,
        statuses = statuses,
    })
    BitbucketState:add_buffer(buffer)
    buffer:show()
end

---@param item PullRequest
local open_in_buf = function(item)
    require("bitbucket.api.comments").get_comments(
        item,
        function(pr_1, comments)
            require("bitbucket.api.activity").get_activity(
                pr_1,
                function(pr, activity)
                    require("bitbucket.api.statuses").get_statuses(
                        pr,
                        function(_, statuses)
                            buf_factory(pr, comments, activity, statuses)
                        end
                    )
                end
            )
        end
    )
end

local M = {}

---@param item PullRequest
---@param _ any
M.select_pr_callback = function(item, _)
    if item == nil then
        return
    end
    open_in_buf(item)
end

---@param item PullRequest
M.open_diff = function(item)
    Git:new({
        callback = function(_)
            -- execute DiffviewOpen
            local source_hash = item.source.commit.hash
            local destination_hash = item.destination.commit.hash

            Git:new({
                callback = function(merge_base_hash)
                    vim.api.nvim_command(
                        ":DiffviewOpen -uno "
                            .. merge_base_hash[1]
                            .. ".."
                            .. source_hash
                    )
                end,
            }):merge_base(source_hash, destination_hash)
        end,
    }):fetch_all()
end

return M
