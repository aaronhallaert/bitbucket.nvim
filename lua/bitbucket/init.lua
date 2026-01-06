local bb_commands = require("bitbucket.commands")
local Env = require("bitbucket.utils.env")

local M = {}

M.setup = function()
    require("bitbucket.utils.colors").setup()
    require("bitbucket.ui.signs").setup()

    -- create Bitbucket command
    vim.api.nvim_create_user_command("Bitbucket", function(opt)
        bb_commands.bitbucket(opt.line1, opt.line2, unpack(opt.fargs))
    end, {
        range = true,
        nargs = "*",
        complete = bb_commands.completion,
    })

    Env:initialize_remote()
end

return M
