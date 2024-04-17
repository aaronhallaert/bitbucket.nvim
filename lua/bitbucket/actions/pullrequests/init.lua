local Git = require("bitbucket.utils.git")

---@param item PullRequest
local open_diff = function(item)
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
    local options = {
        {
            format = "checkout branch",
            callback = function(pr)
                ---@cast pr PullRequest
                pr:checkout()
            end,
        },
        {
            format = "open in browser",
            callback = function(pr)
                ---@cast pr PullRequest
                pr:browse()
            end,
        },
        { format = "open diff", callback = open_diff },
        { format = "open in buffer", callback = open_in_buf },
    }

    vim.ui.select(options, {
        format_item = function(entry)
            return entry.format
        end,
    }, function(action, _)
        action.callback(item)
    end)
end

return M
