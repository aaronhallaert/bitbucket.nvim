---@class Commit
---@field hash string
---@field links table
---@field type "commit"

---@class Branch
---@field name string

---@class PullRequestEndpoint
---@field branch Branch
---@field commit Commit

---@class Account
---@field links table
---@field uuid string
---@field username string
---@field created_on string
---@field display_name string

---@class PRCommentContent
---@field type string
---@field raw string
---@field markup string
---@field html string

---@class User
---@field display_name string
---@field links table
---@field type string
---@field uuid string
---@field account_id string
---@field nickname string

---@class PRCommentLocation
---@field from? number
---@field to? number
---@field path string
--
---@class PRCommentCompact
---@field id number
---@field links

---@class PRComment
---@field user User
---@field content PRCommentContent
---@field parent PRCommentCompact|nil
---@field deleted boolean
---@field inline? PRCommentLocation

---@class Error
---@field type "error"
---@field error ErrorContent

---@class ErrorContent
---@field message string
