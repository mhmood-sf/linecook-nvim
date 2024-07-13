local M = {}

-- TODO: position, encoding, diagnostics.
function M.get_mode()
    -- Note that: \19 = ^S and \22 = ^V.
    local mode_to_str = {
        ['n'] = 'NORMAL',
        ['no'] = 'OP-PENDING',
        ['nov'] = 'OP-PENDING',
        ['noV'] = 'OP-PENDING',
        ['no\22'] = 'OP-PENDING',
        ['niI'] = 'NORMAL',
        ['niR'] = 'NORMAL',
        ['niV'] = 'NORMAL',
        ['nt'] = 'NORMAL',
        ['ntT'] = 'NORMAL',
        ['v'] = 'VISUAL',
        ['vs'] = 'VISUAL',
        ['V'] = 'VISUAL',
        ['Vs'] = 'VISUAL',
        ['\22'] = 'VISUAL',
        ['\22s'] = 'VISUAL',
        ['s'] = 'SELECT',
        ['S'] = 'SELECT',
        ['\19'] = 'SELECT',
        ['i'] = 'INSERT',
        ['ic'] = 'INSERT',
        ['ix'] = 'INSERT',
        ['R'] = 'REPLACE',
        ['Rc'] = 'REPLACE',
        ['Rx'] = 'REPLACE',
        ['Rv'] = 'VIRT REPLACE',
        ['Rvc'] = 'VIRT REPLACE',
        ['Rvx'] = 'VIRT REPLACE',
        ['c'] = 'COMMAND',
        ['cv'] = 'VIM EX',
        ['ce'] = 'EX',
        ['r'] = 'PROMPT',
        ['rm'] = 'MORE',
        ['r?'] = 'CONFIRM',
        ['!'] = 'SHELL',
        ['t'] = 'TERMINAL',
    }

    -- Get the respective string to display.
    return mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
end

function M.get_diagnostic_counts()
    local diagnostics = vim.diagnostics.get(0)

    local ERROR = vim.diagnostic.severity.ERROR
    local WARN = vim.diagnostic.severity.WARN
    local INFO = vim.diagnostic.severity.INFO
    local HINT = vim.diagnostic.severity.HINT

    local counts = {
        [ERROR] = 0,
        [WARN] = 0,
        [INFO] = 0,
        [HINT] = 0
    }

    ---@diagnostic disable-next-line: unused-local
    for i, d in ipairs(diagnostics) do
        counts[d.severity] = counts[d.severity] + 1
    end

    return counts
end

function M.get_pos_info(stl)
    local pos = vim.api.nvim_win_get_cursor(stl.winid)
    return {
        l = pos[1],
        c = pos[2] + 1,
        t = vim.api.nvim_buf_line_count(stl.bufnr)
    }
end

return M
