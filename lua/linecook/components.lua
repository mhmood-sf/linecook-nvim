local M = {}

-- Whitespace.
function M.spacing(count)
    return function()
        return string.rep(" ", count)
    end
end

-- Divide statusline sections.
function M.divider()
    return "%="
end

-- "Raw" text, with an optional wrapper component around it.
function M.raw(val, wrapper)
    return function()
        if wrapper then
            return wrapper(val)
        else
            return val
        end
    end
end

return M
