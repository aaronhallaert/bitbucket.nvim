local Git = require("bitbucket.utils.git")
local Writer = require("bitbucket.ui.writer")

---@param item PullRequest
local open_in_buf = function(item)
    require("bitbucket.api.comments").get_comments(
        item,
        require("bitbucket.actions.comments").display_comments
    )
end

local M = {}

---@param item PullRequest
---@param _ any
M.select_pr_callback = function(item, _)
    open_in_buf(item)
end

---@param item PullRequest
M.open_diff = function(item)
    Git
        :new({
            callback = function(_)
                -- execute DiffviewOpen
                local source_hash = item.source.commit.hash
                local destination_hash = item.destination.commit.hash

                vim.api.nvim_command(
                    ":DiffviewOpen -uno "
                        .. destination_hash
                        .. ".."
                        .. source_hash
                )
            end,
        })
        :fetch_all()
end

return M
