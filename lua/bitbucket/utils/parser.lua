local utils = require("bitbucket.utils")

local M = {}
M.parse_html = function(html)
    local result = html

    result = string.gsub(result, '<img class="emoji".-alt="(.-)".->', "%1")

    result = string.gsub(result, "<code>(.-)</code>", "`%1`")
    -- &gt; &lt; &amp; &quot; &apos; &amp;
    result = string.gsub(result, "&gt;", ">")
    result = string.gsub(result, "&lt;", "<")
    result = string.gsub(result, "&amp;", "&")
    result = string.gsub(result, "&quot;", '"')
    result = string.gsub(result, "&apos;", "'")

    --<ul> <li> tags to *
    result = string.gsub(result, "<p>", "")
    result = string.gsub(result, "</p>", "")
    result = string.gsub(result, "<ul>", "\n")
    result = string.gsub(result, "</ul>", "")
    result = string.gsub(result, "</li>", "")
    result = string.gsub(result, "<li>", "* ")

    -- Remove all other HTML tags
    result = string.gsub(result, "<.->", "")

    -- Remove <200c> character
    result = string.gsub(result, "\226\128\140", "")

    local content = {}
    for _, line in ipairs(utils.split_string(result, "\n")) do
        table.insert(content, { line, "@markup" })
    end

    return content
end
return M
