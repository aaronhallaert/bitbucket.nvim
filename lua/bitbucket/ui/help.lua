local M = {}

M.open = function()
    -- open a floating window with keyboard shortcuts

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = vim.o.lines / 2 - 5,
        col = vim.o.columns / 2 - 20,
        width = 50,
        height = 20,
        style = "minimal",
        border = "single",
    })

    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Bitbucket.nvim Help",
        "",
        "## Global",
        "",
        "g? - Open help",
        "go - Open pull request in browser",
        "gc - Checkout pull request",
        "gd - Open pull request diff",
        "",
        "## Scope: thread",
        "gf - Go to file",
        "<leader>rt - Resolve thread",
        "<leader>ot - Reopen thread",
        "",
        "## Scope: help",
        "q - Close help",
    })

    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "q",
        "<cmd>q!<CR>",
        { noremap = true, silent = true }
    )

    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = buf,
        callback = function()
            vim.api.nvim_win_close(win, true)
        end,
    })
end

return M
