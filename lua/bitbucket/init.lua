local bb_commands = require("bitbucket.commands")

local M = {}

M.setup = function()
    -- create Bitbucket command
    vim.api.nvim_create_user_command("Bitbucket", function(opt)
        bb_commands.bitbucket(unpack(opt.fargs))
    end, {
        range = true,
        nargs = "*",
        complete = bb_commands.completion,
    })
end

return M
