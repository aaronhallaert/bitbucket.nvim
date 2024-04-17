local Env = require("bitbucket.utils.env")
local Logger = require("bitbucket.utils.logger")
local Job = require("plenary.job")

---@class RequestOptions
---@field method "GET"
---@field content_type "application/json"

---@class Request
---@field base_url? string
---@field url string
---@field opts RequestOptions
---@field fn_parser fun(response_body: any): any
---@field fn_handler fun(value: any)
local Request = {}
Request.__index = Request

---@param r Request
function Request:new(r)
    local request = r

    return setmetatable(request, self)
end

local function default_base_url()
    local workspace, repo = Env.workspace, Env.repo
    if workspace == nil or repo == nil then
        vim.print("No workspace or repo found")
        return {}
    end

    return "https://api.bitbucket.org/2.0/repositories/"
        .. workspace
        .. "/"
        .. repo
end

function Request:execute()
    local base_url = self.base_url or default_base_url()

    Job:new({
        command = "curl",
        args = {
            "-X",
            self.opts.method,
            "-H",
            "Content-Type: " .. self.opts.content_type,
            "-u",
            Env.user.username .. ":" .. Env.user.app_password,
            base_url .. self.url,
        },
        on_exit = function(j, return_val)
            if return_val ~= 0 then
                Logger:log(
                    "Request:execute -> on_exit",
                    { on_exit_response = j, return_val = return_val }
                )
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
                    Logger:log(
                        "Request:execute -> on_exit",
                        { response = response }
                    )

                    ---@cast response Error
                    vim.notify(
                        response.error.message,
                        vim.log.levels.ERROR,
                        { title = "Bitbucket.nvim" }
                    )
                    return
                end

                local parsed_value = self.fn_parser(response)

                self.fn_handler(parsed_value)
            end)
        end,
    }):start()
end

return Request
