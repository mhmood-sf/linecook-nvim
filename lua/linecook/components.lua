local M = {}

function M.spacing(count)
    return function()
        return string.rep(" ", count)
    end
end

function M.divider()
    return "%="
end

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
