---@class PRCommentContent
---@field type string
---@field raw string
---@field markup string
---@field html string

---@class PRCommentLocation
---@field from? number
---@field to? number
---@field path string

---@class PRCommentCompact
---@field id number
---@field links table

---@class PRComment
---@field id any
---@field user User
---@field content PRCommentContent
---@field parent PRCommentCompact|nil
---@field deleted boolean
---@field inline? PRCommentLocation
