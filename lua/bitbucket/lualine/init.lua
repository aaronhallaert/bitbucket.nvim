local Env = require("bitbucket.utils.env")
local M = {}

local component_content = function(request)
    local component_value = "-"
    local last_refresh = nil
    local update_component_value = function(prs)
        component_value = string.format("%d", #prs)
    end

    return function()
        -- only refresh every 5 minutes
        if last_refresh ~= nil and os.time() - last_refresh < 300 then
            return component_value
        end

        request(update_component_value)

        last_refresh = os.time()

        return component_value
    end
end

M.component_pr_reviewing = {
    component_content(
        require("bitbucket.api.pullrequests").get_pull_requests_to_review
    ),
    separator = { left = "", right = "" },
    color = { bg = "#313244", fg = "#80A7EA" },
    icon = " ",
    cond = function()
        return Env:is_bitbucket() and Env:is_auth()
    end,
    on_click = function(n, mouse)
        if n == 1 then
            if mouse == "l" then
                vim.cmd("Bitbucket pull reviewing")
            end
        end
    end,
}

M.component_pr_mine = {
    component_content(
        require("bitbucket.api.pullrequests").get_my_pull_requests
    ),
    separator = { left = "", right = "" },
    color = { bg = "#313244", fg = "#80A7EA" },
    icon = " ",
    cond = function()
        return Env:is_bitbucket() and Env:is_auth()
    end,
    on_click = function(n, mouse)
        if n == 1 then
            if mouse == "l" then
                vim.cmd("Bitbucket pull mine")
            end
        end
    end,
}

return M
