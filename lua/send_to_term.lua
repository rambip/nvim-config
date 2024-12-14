local M = {}


-- Determine newline based on OS
local nl = vim.fn.has('win32') == 1 and '\r\n' or '\n'

-- Multiline sending configurations
local send_multiline = {
    default = {begin_pos = '', end_pos = nl, newline = nl},
    ipy = {begin = '\27[200~', end_pos = '\27[201~\r\r\r', newline = nl}
}

-- Extend or set global multiline settings
if vim.g.send_multiline then
    for k, v in pairs(send_multiline) do
        if vim.g.send_multiline[k] == nil then
            vim.g.send_multiline[k] = v
        end
    end
else
    vim.g.send_multiline = send_multiline
end

-- Send to current terminal
function M.send_here(term_type)
    term_type = term_type or 'default'
    
    if not vim.b.terminal_job_id then
        vim.notify('This buffer is not a terminal.', vim.log.levels.WARN)
        return
    end

    vim.g.send_target = {
        term_id = vim.b.terminal_job_id,
        send = M.send_lines_to_term,
        begin_pos = vim.g.send_multiline[term_type].begin_pos,
        end_pos = vim.g.send_multiline[term_type].end_pos,
        newline = vim.g.send_multiline[term_type].newline
    }
end

-- Get available terminal types for completion
function M.send_opts(_, _, _)
    return vim.tbl_keys(vim.g.send_multiline)
end


local function remove_whitespace_lines(lines)
    local result = {}
    for _, line in ipairs(lines) do
        -- Use pattern matching to check if line contains only whitespace
        if not line:match("^%s*$") then
            table.insert(result, line)
        end
    end
    return result
end

-- Core function to send lines to terminal
function M.send_lines_to_term(lines)
    local send_target = vim.g.send_target
    lines = remove_whitespace_lines(lines)
    local line

    if #lines > 1 then
        line = send_target.begin_pos .. table.concat(lines, send_target.newline) .. send_target.end_pos .. "\n"
    else
        line = lines[1] .. nl
    end

    vim.fn.jobsend(send_target.term_id, line)

    -- Slow down for multiple command sends
    if vim.v.count1 > 1 then
        vim.fn.sleep(100)
    end
end

-- Main send function handling different modes
function M.send(mode, ...)
    if not vim.g.send_target then
        vim.notify('Target terminal not set. Run :SendHere or :SendTo first.', vim.log.levels.WARN)
        return
    end

    local lines

    if mode == 'direct' then
        lines = {...}
    else
        local marks = (mode:lower() == 'v') and {"'<", "'>"} or {"'[", "']"}
        lines = vim.fn.getline(marks[1], marks[2])

        if mode == 'char' or mode == 'v' then
            local col0 = vim.fn.col(marks[1]) - 1
            local col1 = vim.fn.col(marks[2]) - 1

            if #lines == 1 then
                lines[1] = lines[1]:sub(col0 + 1, col1 + 1)
            else
                lines[1] = lines[1]:sub(col0 + 1)
                lines[#lines] = lines[#lines]:sub(1, col1 + 1)
            end
        end
    end

    vim.g.send_target.send(lines)
end

_G.send_to_term = M.send

-- Function to clear the terminal using Ctrl-L
function M.clear_terminal()
    if not vim.g.send_target then
        vim.notify('Target terminal not set. Run :SendHere or :SendTo first.', vim.log.levels.WARN)
        return
    end
    
    -- Send Ctrl-L (ASCII form \x0C) to clear screen
    vim.fn.jobsend(vim.g.send_target.term_id, "\x0C")
end

-- Create user commands
vim.api.nvim_create_user_command('SendHere', function(opts)
    M.send_here(opts.args ~= '' and opts.args or nil)
end, {
    nargs = '?',
    complete = function() return M.send_opts() end
})

-- Create command to clear terminal
vim.api.nvim_create_user_command('SendClear', function()
    M.clear_terminal()
end, {})

return M
