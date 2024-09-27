local Logger = require("bitbucket.utils.logger")
local bb_ns = require("bitbucket.utils.ns")
---@class Writer
local Writer = {}

Writer.__index = Writer

-- octo.nvim
local function write_virtual_text(bufnr, ns, line, chunks, mode)
    mode = mode or "extmark"
    if mode == "extmark" then
        pcall(vim.api.nvim_buf_set_extmark, bufnr, bb_ns.global, line, 0, {
            virt_text = chunks,
            virt_text_pos = "overlay",
            hl_mode = "combine",
        })
    elseif mode == "vt" then
        pcall(vim.api.nvim_buf_set_virtual_text, bufnr, ns, line, chunks, {})
    end
end

local function write_block(bufnr, lines, line, mark)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    line = line or vim.api.nvim_buf_line_count(bufnr) + 1
    mark = mark or false

    if type(lines) == "string" then
        lines = vim.split(lines, "\n", true)
    end

    -- write content lines
    vim.api.nvim_buf_set_lines(bufnr, line - 1, line - 1 + #lines, false, lines)

    -- set extmarks
    if mark then
        -- (empty line) start ext mark at 0
        -- start line
        -- ...
        -- end line
        -- (empty line)
        -- (empty line) end ext mark at 0
        --
        -- (except for title where we cant place initial mark on line -1)

        local start_line = line
        local end_line = line
        local count = start_line + #lines
        for i = count, start_line, -1 do
            local text = vim.fn.getline(i) or ""
            if "" ~= text then
                end_line = i
                break
            end
        end

        return vim.api.nvim_buf_set_extmark(
            bufnr,
            bb_ns,
            math.max(0, start_line - 1 - 1),
            0,
            {
                end_line = math.min(
                    end_line + 2 - 1,
                    vim.api.nvim_buf_line_count(bufnr)
                ),
                end_col = 0,
            }
        )
    end
end

local function write_event(bufnr, vt)
    local line = vim.api.nvim_buf_line_count(bufnr) - 1
    write_block(bufnr, { "" }, line + 2)
    write_virtual_text(bufnr, bb_ns, line, vt)
end

function Writer:new()
    local writer = setmetatable({}, self)

    return writer
end

---@param bufnr number
---@param text string[][]
---@return number start_line
---@return number end_line
function Writer:write(bufnr, text)
    local start_line = vim.api.nvim_buf_line_count(bufnr)
    for _, chunk in ipairs(text) do
        if #chunk == 1 and type(chunk[1]) == "string" then
            write_block(bufnr, chunk[1])
            write_block(bufnr, { "" })
        elseif type(chunk[1]) == "table" then
            write_event(bufnr, chunk)
        else
            write_event(bufnr, { chunk })
        end
    end

    local end_line = vim.api.nvim_buf_line_count(bufnr)
    return start_line, end_line
end

return Writer:new()
