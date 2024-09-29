local icons = require("bitbucket.ui.icons")
local bubble = require("bitbucket.ui.bubble")
local Logger = require("bitbucket.utils.logger")
---@class PRSummary
---@field raw string
---@field markup "markdown"|"creole"|"plaintext"
---@field html string

---@class PullRequestEndpoint
---@field branch Branch
---@field commit Commit

---@class Branch
---@field name string

---@class PullRequest
---@field id number
---@field state "OPEN"|"MERGED"|"DECLINED"|"SUPERSEDED"
---@field merge_commit string
---@field title string
---@field links table
---@field summary PRSummary
---@field author Account
---@field source PullRequestEndpoint
---@field destination PullRequestEndpoint
local PullRequest = {}

PullRequest.__index = PullRequest

---@param o PullRequest
---@return PullRequest
function PullRequest:new(o)
    local obj = o

    return setmetatable(obj, self)
end

function PullRequest:browse()
    vim.ui.open(self.links.html.href)
end

function PullRequest:checkout()
    local command = "git fetch origin "
        .. self.source.branch.name
        .. " && git checkout "
        .. self.source.branch.name
        .. " && git pull"

    vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_exit = function(_, exit_code, _)
            if exit_code == 0 then
                vim.notify(
                    "Switched to branch " .. self.source.branch.name,
                    vim.log.levels.INFO,
                    { title = "Bitbucket.nvim" }
                )
            else
                vim.notify(
                    "Failed to checkout: " .. self.source.branch.name,
                    vim.log.levels.ERROR,
                    { title = "Bitbucket.nvim" }
                )
                Logger.log(
                    "PullRequest:checkout",
                    { pr = self, command = command }
                )
            end
        end,
    })
end

---@return table
function PullRequest:display()
    local contents = {}

    table.insert(contents, {
        { icons.pullrequest .. "Title: ", "Title" },
        { self.title, "Normal" },
    })

    table.insert(contents, {
        { icons.user .. "Author: ", "Title" },
        { self.author.display_name, "Normal" },
    })

    table.insert(
        contents,
        { { "Source: ", "Title" }, { self.source.branch.name, "Normal" } }
    )

    table.insert(contents, {
        { "Destination: ", "Title" },
        { self.destination.branch.name, "Normal" },
    })

    if self.state == "MERGED" then
        table.insert(contents, bubble.make_bubble("Merged", "green"))
    elseif self.state == "DECLINED" then
        table.insert(contents, bubble.make_bubble("Declined", "red"))
    elseif self.state == "SUPERSEDED" then
        table.insert(contents, bubble.make_bubble("Superseded", "yellow"))
    else
        table.insert(contents, bubble.make_bubble("Open", "blue"))
    end

    table.insert(contents, { "" })

    for _, line in
        ipairs(require("bitbucket.utils.parser").parse_html(self.summary.html))
    do
        table.insert(contents, line)
    end

    table.insert(contents, { "" })
    table.insert(contents, { "" })
    return contents
end

return PullRequest
