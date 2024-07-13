local M = {}

---@alias Component fun(): string
---@alias Container fun(inner: string): string

---@class StyleOpts
---@field fg string? Foreground color.
---@field bg string? Background color.
---@field sp string? Special color.
---@field gui string? Font attributes such as bold, italics, etc.

---@class SeparatorOpts
---@field sep string The separator string.
---@field pad number? The padding applied to the separator (where it is applied depends on whether it is the left or right separator).
---@field style StyleOpts? Style options for the separator.

---@class ContainerOpts
---@field name string Name for the container, used for highlight groups. Must not contain spaces or special characters.
---@field left SeparatorOpts? Options for the left separator.
---@field right SeparatorOpts? Options for the right separator.
---@field style StyleOpts? Style options for the content of the container.
---@field reset string? The highlight group to switch back to after drawing. Defaults to "StatusLine".

---@class StatuslineInfo
---@field active boolean Whether this statusline is the current one or not.
---@field winid number Window handle for the associated statusline.
---@field bufnr number Buffer handle for the buffer associated with the current window.

---Create an ID string given a name and category.
---@param name string
---@param category string
---@return string
function M.mk_id(name, category)
    return "LINECOOK_" .. category .. "_" .. name
end

---Define (or update) a highlight group.
---@param group string Highlight group name.
---@param style StyleOpts Attributes for the highlight command:
function M.hi(group, style)
    local attrs = " "
    attrs = attrs .. "guifg=" .. (style.fg  or "NONE") .. " "
    attrs = attrs .. "guibg=" .. (style.bg  or "NONE") .. " "
    attrs = attrs .. "guisp=" .. (style.sp  or "NONE") .. " "
    attrs = attrs .. "gui="   .. (style.gui or "NONE") .. " "

    vim.cmd("highlight " .. group .. attrs)
end

---Create a custom container for components (that is, left/right separators).
---This container can then be reused across components. Note that this
---function always creates three highlight groups (left, inner, right),
---regardless of whether they are actually used or not. To avoid this,
---use mk_plain_container (with your own highlight groups).
---@param opts ContainerOpts Options for the container
---@return Container
function M.mk_container(opts)
    local id = M.mk_id(opts.name, "CONTAINER")
    -- Make highlight group names.
    local hl_inner = id .. "_INNER"
    local hl_left = id .. "_LEFT"
    local hl_right = id .. "_RIGHT"
    local hl_reset = opts.reset or "StatusLine"

    local inner_style = opts.style or {}
    local left_style = opts.left and opts.left.style or {}
    local right_style = opts.right and opts.right.style or {}

    -- Create highlight groups.
    M.hi(hl_inner, inner_style)
    M.hi(hl_left, left_style)
    M.hi(hl_right, right_style)

    local left_pad = string.rep(" ", opts.left and opts.left.pad or 0)
    local right_pad = string.rep(" ", opts.right and opts.right.pad or 0)

    local left_sep = opts.left and opts.left.sep or ""
    local right_sep = opts.right and opts.right.sep or ""

    -- Return function that will wrap around the inner component value.
    return function(inner)
        -- Only render container if contents are non-empty
        if inner == "" then
            return ""
        else
            return table.concat {
                string.format("%%#%s#%s%%#%s#", hl_left, left_sep, hl_reset),
                string.format("%%#%s#%s", hl_inner, left_pad),
                inner,
                string.format("%s%%#%s#", right_pad, hl_reset),
                string.format("%%#%s#%s%%#%s#", hl_right, right_sep, hl_reset),
            }
        end
    end
end

---Create a plain container consisting of just the left and right separators,
---with no styling applied. You can use your own styling by directly putting
---it inside the strings for the separators.
---@param left string Left separator.
---@param right string Right separator.
---@return Container
function M.mk_plain_container(left, right)
    return function(inner)
        return table.concat { left, inner, right }
    end
end

---Takes a list of components and returns a function that renders the
---statusline string.
---@param components table<Component>
---@return fun(): string
function M.mk_renderer(components)
    return function()
        local winid = vim.g.statusline_winid

        ---@type StatuslineInfo
        local stl = {
            active = winid == vim.api.nvim_get_current_win(),
            winid = winid,
            bufnr = vim.api.nvim_win_get_buf(winid)
        }

        local acc = {}

        -- Run each component and accumulate the results.
        ---@diagnostic disable-next-line: unused-local
        for _i, c in ipairs(components) do
            table.insert(acc, c(stl))
        end

        return table.concat(acc)
    end
end

return M
