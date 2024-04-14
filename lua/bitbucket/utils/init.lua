local M = {}

---@return table
M.split_string = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

M.url_encode = function(str)
    if type(str) ~= "number" then
        str = str:gsub("\r?\n", "\r\n")
        str = str:gsub("([^%w%-%.%_%~ ])", function(c)
            return string.format("%%%02X", c:byte())
        end)
        str = str:gsub(" ", "+")
        return str
    else
        return str
    end
end

---@param t table
M.read_only = function(t)
    local proxy = {}
    local mt = { -- create metatable
        __index = t,
        __newindex = function(t, k, v)
            error("attempt to update a read-only table", 2)
        end,
    }
    setmetatable(proxy, mt)
    return proxy
end

M.parse_html = function(html)
    local result = html

    result = string.gsub(result, '<img class="emoji".-alt="(.-)".->', "%1")

    result = string.gsub(result, "<code>(.-)</code>", "`%1`")

    -- Remove all other HTML tags
    result = string.gsub(result, "<.->", "")

    return M.split_string(result, "\n")
end

return M
