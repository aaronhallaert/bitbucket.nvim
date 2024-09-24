local M = {}

---@alias BubbleColor "red" | "green" | "yellow" | "blue"

---@type table<BubbleColor, string>
local bubble_text_hl = {
    red = "BitbucketBubbleRed",
    green = "BitbucketBubbleGreen",
    yellow = "BitbucketBubbleYellow",
    blue = "BitbucketBubbleBlue",
}

---@type table<BubbleColor, string>
local bubble_border_hl = {
    red = "BitbucketBubbleDelimiterRed",
    green = "BitbucketBubbleDelimiterGreen",
    yellow = "BitbucketBubbleDelimiterYellow",
    blue = "BitbucketBubbleDelimiterBlue",
}

local right_bubble_delimiter = ""
local left_bubble_delimiter = ""

---@param text string
---@param color BubbleColor
M.make_bubble = function(text, color)
    local hl = bubble_text_hl[color]
    local border_hl = bubble_border_hl[color]
    return {
        {
            left_bubble_delimiter,
            border_hl,
        },
        {
            text,
            hl,
        },
        {
            right_bubble_delimiter,
            border_hl,
        },
    }
end

return M
