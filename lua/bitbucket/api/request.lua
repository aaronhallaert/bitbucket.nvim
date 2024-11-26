local Env = require("bitbucket.utils.env")
local Logger = require("bitbucket.utils.logger")
local Job = require("plenary.job")

---@class RequestOptions
---@field method "GET" | "POST" | "DELETE"
---@field content_type "application/json"|nil
---@field body table|nil

---@class Request
---@field base_url? string
---@field url string
---@field opts RequestOptions
---@field fn_parser (fun(response_body: any): any)|nil
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

    local args = {
        "-X",
        self.opts.method,
        "-u",
        Env.user.username .. ":" .. Env.user.app_password,
        base_url .. self.url,
    }

    if self.opts.content_type then
        table.insert(args, "-H")
        table.insert(args, "Content-Type: " .. self.opts.content_type)
    end

    if self.opts.body then
        table.insert(args, "-d")
        Logger:log("Request:execute", { body = self.opts.body })
        table.insert(args, vim.fn.json_encode(self.opts.body))
        -- table.insert(args, self.opts.body)
    end

    Job
        :new({
            command = "curl",
            args = args,
            on_exit = function(j, return_val)
                if return_val ~= 0 then
                    Logger:log(
                        "Request:execute -> on_exit",
                        { on_exit_response = j, return_val = return_val }
                    )
                    vim.notify(
                        "Could not execute request",
                        vim.log.levels.ERROR
                    )
                    return
                end

                local result = j:result()[1]

                if result == nil then
                    self.fn_handler(nil)
                    return
                end

                vim.schedule(function()
                    Logger:log(
                        "Request:execute -> on_exit",
                        { result = result }
                    )
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

                    if self.fn_parser == nil then
                        self.fn_handler(response)
                        return
                    end

                    local parsed_value = self.fn_parser(response)

                    self.fn_handler(parsed_value)
                end)
            end,
        })
        :start()
end

return Request
