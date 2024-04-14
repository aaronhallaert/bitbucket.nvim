local config = require("bitbucket.utils.config")
local auth_info = config.user_data()
local Job = require("plenary.job")

local M = {}

---@class RequestOptions
---@field method "GET"
---@field content_type string

---@param url string
---@param opt RequestOptions
---@param callback function(response: table): void
M.execute_request = function(url, opt, callback)
    Job:new({
        command = "curl",
        args = {
            "-X",
            opt.method,
            "-H",
            "Content-Type: " .. opt.content_type,
            "-u",
            auth_info.username .. ":" .. auth_info.app_password,
            url,
        },
        on_exit = function(j, return_val)
            if return_val ~= 0 then
                vim.notify("Could not execute request", vim.log.levels.ERROR)
                return
            end

            local result = j:result()[1]

            vim.schedule(function()
                local response = vim.json.decode(
                    result,
                    { luanil = { object = true, array = true } }
                )

                if response.type == "error" then
                    ---@cast response Error
                    vim.notify(
                        response.error.message,
                        vim.log.levels.ERROR,
                        { title = "Bitbucket.nvim" }
                    )
                    return
                end
                callback(response)
            end)
        end,
    }):start()
end

---@type string
M.current_user = auth_info.username

return M
