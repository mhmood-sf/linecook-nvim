local linecook = require("linecook")
local lc_components = require("linecook.components")
local lc_containers = require("linecook.containers")

local myModeContainer = linecook.mk_container {
    name = "myModeContainer",
    style = { fg = "black", bg = "white" },
    right = {
        sep = "",
        pad = 1,
        style = { fg = "white" }
    },
    left = {
        sep = "",
        pad = 1
    }
}

local myFtContainer = lc_containers.plain("myFtContainer", {
    bg = "white", fg = "black"
})

local function myModeComponent()
    return myModeContainer(string.upper(vim.fn.mode()))
end

local function myFtComponent(stl)
    return myFtContainer(vim.api.nvim_get_option_value("filetype", { buf = stl.bufnr }))
end

local render = linecook.mk_renderer {
    myModeComponent,
    lc_components.divider,
    myFtComponent,
}

vim.o.stl = "%!v:lua.require'linecook.test'.render()"

return { render = render }
