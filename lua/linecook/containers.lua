local M = {}

local lc = require("linecook")

-- TODO: slants, arrows, plain, etc.

---Create a bubble container.
---@param name string
---@param opts StyleOpts
function M.bubble(name, opts)
    return lc.mk_container {
        name = name,
        style = opts,
        left = {
            sep = "",
            style = { fg = opts.bg }
        },
        right = {
            sep = "",
            style = { fg = opts.bg }
        }
    }
end

---Create a left-slant container.
---@param name string
---@param opts StyleOpts
function M.slant_left(name, opts)
    return lc.mk_container {
        name = name,
        style = opts,
        left = {
            sep = "",
            pad = 1,
            style = { fg = opts.bg, bg = opts.fg }
        },
        right = {
            sep = "",
            pad = 1,
            style = { fg = opts.bg }
        }
    }
end

---Create a right-slant container.
---@param name string
---@param opts StyleOpts
function M.slant_right(name, opts)
    return lc.mk_container {
        name = name,
        style = opts,
        left = {
            sep = "",
            pad = 1,
            style = { fg = opts.bg, bg = opts.fg }
        },
        right = {
            sep = "",
            pad = 1,
            style = { fg = opts.bg }
        }
    }
end

---Create a container with no special separators.
---@param name string
---@param opts StyleOpts
function M.plain(name, opts)
    return lc.mk_container {
        name = name,
        style = opts
    }
end

return M
