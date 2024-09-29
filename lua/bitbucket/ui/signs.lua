local M = {}

function M.setup()
    vim.cmd(
        [[sign define bb_comment_start text=┌ texthl=Comment linehl=Comment]]
    )
    vim.cmd([[sign define bb_comment_end text=└ texthl=Comment]])
    vim.cmd([[sign define bb_comment_middle text=│ texthl=Comment]])
end

function M.place_comment_sign(buf_id, start_line, end_line)
    vim.fn.sign_place(
        start_line,
        "bb_comment",
        "bb_comment_start",
        buf_id,
        { lnum = start_line, priority = 100 }
    )
    vim.fn.sign_place(
        end_line,
        "bb_comment",
        "bb_comment_end",
        buf_id,
        { lnum = end_line, priority = 100 }
    )
    for i = start_line + 1, end_line - 1 do
        vim.print(i)
        vim.fn.sign_place(
            i,
            "bb_comment",
            "bb_comment_middle",
            buf_id,
            { lnum = i, priority = 100 }
        )
    end
end

return M
