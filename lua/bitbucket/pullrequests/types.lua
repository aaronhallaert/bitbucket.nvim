---@class Commit
---@field hash string
---@field links table
---@field type "commit"

---@class Branch
---@field name string

---@class PullRequestEndpoint
---@field branch Branch
---@field commit Commit

---@class PullRequest
---@field id number
---@field title string
---@field links table
---@field summary string html
---@field author string
---@field source PullRequestEndpoint
---@field destination PullRequestEndpoint
