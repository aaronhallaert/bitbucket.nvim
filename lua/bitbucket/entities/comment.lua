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

---@class CommentResolution
---@field type "comment_resolution"
---@field user Account
---@field created_on string

---@class PRComment
---@field type string
---@field id any
---@field user User
---@field content PRCommentContent
---@field parent PRCommentCompact|nil
---@field deleted boolean
---@field updated_on string
---@field pending boolean
---@field resolution CommentResolution|nil
---@field inline? PRCommentLocation
