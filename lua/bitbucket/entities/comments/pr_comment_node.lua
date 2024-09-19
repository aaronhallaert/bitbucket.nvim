local Git = require("bitbucket.utils.git")
local utils = require("bitbucket.utils")

---@class PRCommentNode: PRComment
---@field children PRCommentNode[]
local PRCommentNode = {}

PRCommentNode.__index = PRCommentNode

---Public functions

---@param node PRComment
---@return PRCommentNode
function PRCommentNode:new(node)
    local obj = node

    ---@cast obj PRCommentNode
    obj.children = obj.children or {}

    return setmetatable(obj, self)
end

---@return boolean
function PRCommentNode:is_root()
    return self.parent == nil
end

---@return boolean
function PRCommentNode:is_general_comment()
    return self.inline == nil
end

---@return boolean
function PRCommentNode:is_inline()
    return self.inline ~= nil
end

--- Private functions

---@return table
function PRCommentNode:_parse_content()
    -- return require("bitbucket.utils").split_string(self.content.raw, "\n")
    return require("bitbucket.utils.parser").parse_html(self.content.html)
end

---@return table
function PRCommentNode:_display_location()
    if self.inline == nil then
        return {}
    end

    local line_loc = {}

    if self.inline.from ~= nil then
        table.insert(
            line_loc,
            self.inline.path .. ":" .. tostring(self.inline.from) .. " (old)"
        )
    elseif self.inline.to ~= nil then
        table.insert(
            line_loc,
            self.inline.path .. ":" .. tostring(self.inline.to) .. " (new)"
        )
    end

    return line_loc
end

---@param pr PullRequest
---@param opts table
---@return table
function PRCommentNode:display(pr, opts)
    opts = vim.tbl_extend("keep", opts or {}, { indent = 0 })
    local prefix = string.rep("\t", opts.indent + 1)

    local contents = {}

    if not self:is_general_comment() and self:is_root() then
        table.insert(contents, { "> THREAD" })
        if self.pending then
            table.insert(contents, { "Pending", "BitbucketStatePendingBubble" })
        end

        if self:is_inline() and pr.source ~= nil then
            for _, line in ipairs(self:_display_location()) do
                table.insert(contents, { prefix .. line, "Comment" })
            end
            table.insert(contents, { "" })

            local anchor = self.inline.to or self.inline.from or 0

            local diff_contents = Git:new({ sync = true }):show_diff_line({
                from_hash = pr.destination.commit.hash,
                to_hash = pr.source.commit.hash,
                from_line = anchor - 3,
                to_line = anchor,
                filename = self.inline.path,
            })

            if diff_contents == nil or #diff_contents == 0 then
                goto comment
            end

            for _, line in ipairs(diff_contents) do
                if line:find("^+") then
                    table.insert(contents, { line, "diffAdd" })
                elseif line:find("^-") then
                    table.insert(contents, { line, "diffDelete" })
                elseif line:find("^@") then
                    table.insert(contents, { line, "diffIndexLine" })
                end
            end
            table.insert(contents, { "" })
        end
    end

    ::comment::
    table.insert(contents, {
        prefix
            .. "  "
            .. self.user.display_name
            .. " ("
            .. utils.time_difference(self.updated_on)
            .. ")",
        "SubTitle",
    })
    table.insert(contents, { prefix .. "-----------------", "Comment" })
    if self.content ~= nil then
        for _, line in ipairs(self:_parse_content()) do
            local text = line[1]
            local hi = line[2] or "Comment"
            table.insert(contents, { prefix .. text, hi })
        end
    end

    return contents
end

--- Static functions

---@param comments PRComment[]
---@return PRCommentNode[]
PRCommentNode.create_tree = function(comments)
    local nodes = {}
    for _, comment in ipairs(comments) do
        table.insert(nodes, PRCommentNode:new(comment))
    end

    ---@return table<string, PRCommentNode[]> grouped_comments -- read only
    local function group_by_parents(cmts)
        -- Initialize a table to hold comments grouped by parent ID
        local comments_by_parent = {}

        -- Group comments by parent ID
        for _, comment in ipairs(cmts) do
            if comment.parent then
                -- If the comment has a parent, add it to the parent's children list
                if not comments_by_parent[comment.parent.id] then
                    comments_by_parent[comment.parent.id] = {}
                end
                table.insert(comments_by_parent[comment.parent.id], comment)
            end
        end

        return require("bitbucket.utils").read_only(comments_by_parent)
    end

    local comments_by_parent = group_by_parents(comments)

    ---Function to recursively nest comments under their parent comments
    ---@param comment PRCommentNode
    local function nest_comments(comment)
        -- If the comment has children, nest them recursively
        if comments_by_parent[comment.id] then
            for _, child_comment in ipairs(comments_by_parent[comment.id]) do
                nest_comments(child_comment)
            end
            -- Assign nested children to the comment
            comment.children = comments_by_parent[comment.id]
        else
            -- If there are no children, assign an empty list
            comment.children = {}
        end
    end

    -- Recursively nest comments under their parent comments
    for _, comment in ipairs(nodes) do
        -- If the comment has no parent, start nesting from it
        if not comment.parent then
            nest_comments(comment)
        end
    end

    -- The root_comments table now contains the top-level comments with nested children
    local root_comments = {}
    for _, comment in ipairs(comments) do
        if not comment.parent then
            table.insert(root_comments, comment)
        end
    end

    return root_comments
end

return PRCommentNode
