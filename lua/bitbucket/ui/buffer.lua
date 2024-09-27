local navigation = require("bitbucket.ui.navigation")
local ns = require("bitbucket.utils.ns")

---@class Buffer
---@field buf_id number
---@field pr PullRequest
---@field threads ThreadMeta[]
local Buffer = {}

Buffer.__index = Buffer

---@return Buffer
function Buffer:new(o)
    local obj = vim.tbl_extend("keep", o or {}, { threads = {} })

    -- create keymap only for filetype bitbucket_ft
    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "gf", "", {
        callback = function()
            navigation.goto_file(obj.buf_id)
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "go", "", {
        callback = function()
            obj.pr:browse()
        end,
    })

    vim.api.nvim_buf_set_keymap(obj.buf_id, "n", "gd", "", {
        callback = function()
            require("bitbucket.actions.pullrequests").open_diff(obj.pr)
        end,
    })

    return setmetatable(obj, self)
end

---@param thread ThreadMeta
function Buffer:add_thread(thread)
    local mark_id = vim.api.nvim_buf_set_extmark(
        self.buf_id,
        ns.thread,
        thread.start_line_mark - 1,
        0,
        {
            end_row = thread.end_line_mark,
        }
    )

    thread.mark_id = mark_id

    table.insert(self.threads, thread)
end

---@param mark_id number
---@return ThreadMeta|nil
function Buffer:get_thread_by_mark_id(mark_id)
    for _, thread in ipairs(self.threads) do
        if thread.mark_id == mark_id then
            return thread
        end
    end
end

return Buffer
