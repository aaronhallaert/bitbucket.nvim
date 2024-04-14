---@class PRSummary
---@field raw string
---@field markup "markdown"|"creole"|"plaintext"
---@field html string

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

---@return table
function PullRequest:display()
    local contents = {}

    table.insert(contents, "# " .. self.title)
    table.insert(contents, "")
    table.insert(
        contents,
        string.format(
            "`%s` -> `%s`",
            self.source.branch.name,
            self.destination.branch.name
        )
    )
    table.insert(
        contents,
        require("bitbucket.utils").parse_html(self.summary.html)
    )

    table.insert(contents, "")
    table.insert(contents, "")
    return contents
end

return PullRequest
