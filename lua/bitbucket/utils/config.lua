local Path = require("plenary.path")
local data_path = vim.fn.stdpath("data")

-- should contain
-- username: "your_username"
-- app_password: "your_app_password"
local user_data_path = string.format("%s/bitbucket.json", data_path)

local read_user_data = function()
    return vim.json.decode(
        Path:new(user_data_path):read(),
        { luanil = { object = true, array = true } }
    )
end

---@class AppUserInfo
---@field username string
---@field app_password string

---Request user data from input
---@param default AppUserInfo|nil
---@return AppUserInfo
local request_user_data = function(default)
    default = vim.tbl_extend(
        "keep",
        default or {},
        { username = "", app_password = "" }
    )

    local username = vim.fn.input({
        prompt = "username [" .. default.username .. "]: ",
        default = default.username,
    })
    local app_password = vim.fn.input({
        prompt = "app_password [" .. default.app_password .. "]: ",
        default = default.app_password,
    })

    return {
        username = username,
        app_password = app_password,
    }
end

local save_user_data = function(user)
    Path:new(user_data_path):write(vim.fn.json_encode(user), "w")
end

local M = {}

---@return AppUserInfo user
M.user_data = function()
    local ok, stored_user_data = pcall(read_user_data)
    local user = {}

    if not ok or stored_user_data == nil then
        vim.print("bitbucket.nvim: No user data provided...")
        user = request_user_data()
    elseif stored_user_data ~= nil then
        if
            stored_user_data.username == nil
            or stored_user_data.username == ""
            or stored_user_data.app_password == nil
            or stored_user_data.app_password == ""
        then
            user = request_user_data()
        else
            user = stored_user_data
        end
    end

    save_user_data(user)

    return user
end

return M
