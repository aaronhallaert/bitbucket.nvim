local parse = require("bitbucket.api")

---@param item PullRequest
local checkout_pr = function(item)
    vim.fn.jobstart(
        "git fetch origin "
            .. item.source.branch.name
            .. " && git checkout "
            .. item.source.branch.name
            .. " && git pull",
        {
            stdout_buffered = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    vim.print("Switched to branch: " .. item.source.branch.name)
                else
                    vim.print("Failed to switch to branch")
                end
            end,
        }
    )
end

---@param item PullRequest
local open_pr = function(item)
    vim.fn.jobstart("open " .. item.links.html.href)
end
--
---@param item PullRequest
local open_diff = function(item)
    require("bitbucket.utils.git").fetch_all()
    -- execute DiffviewOpen
    local source_hash = item.source.commit.hash
    local destination_hash = item.destination.commit.hash

    vim.api.nvim_command(
        ":DiffviewOpen -uno " .. destination_hash .. ".." .. source_hash
    )
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
        { format = "checkout branch", callback = checkout_pr },
        { format = "open in browser", callback = open_pr },
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
