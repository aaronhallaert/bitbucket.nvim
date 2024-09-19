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

function M.is_white_space(str)
    return str:gsub("%s", "") == ""
end

function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

function M.remove_duplicate_whitespace(str)
    return str:gsub("%s+", " ")
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

-- Function to parse ISO 8601 format to Lua time table
local function parse_iso8601(timestamp)
    -- Extract date and time components from the string
    local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = timestamp:match(pattern)

    -- Convert to a table for os.time() to work with
    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec),
    })
end

-- Function to calculate time difference
M.time_difference = function(timestamp)
    local parsed_time = parse_iso8601(timestamp)

    -- Get the current time (in UTC)
    local current_time = os.time(os.date("!*t"))

    -- Calculate the difference in seconds
    local diff = os.difftime(current_time, parsed_time)

    if diff >= (3600 * 24) then
        local days_ago = math.floor(diff / 3600 / 24)
        return days_ago .. " days ago"
    elseif diff >= 3600 then
        local hours_ago = math.floor(diff / 3600)
        return hours_ago .. " hours ago"
    else
        -- Otherwise, show minutes ago
        local minutes_ago = math.floor(diff / 60)
        return minutes_ago .. " minutes ago"
    end
end

return M
