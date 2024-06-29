---@class Writer
local Writer = {}

Writer.__index = Writer

function Writer:new()
    local writer = setmetatable({}, self)

    return writer
end

---@param bufnr number
---@param text string[]
---@return number start_line
---@return number end_line
function Writer:write(bufnr, text)
    local start_line = vim.api.nvim_buf_line_count(bufnr) + 1

    local start_idx = -1
    if
        start_line == 2
        and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
    then
        start_idx = 0
        start_line = 1
    end

    vim.api.nvim_buf_set_lines(
        bufnr,
        start_idx,
        -1,
        true,
        vim.iter(text):flatten():totable()
    )

    local end_line = vim.api.nvim_buf_line_count(bufnr)

    return start_line, end_line
end

return Writer:new()
