local M = {}

M.openCurrentDir = function()
    local current_file = vim.fn.expand('%:p:h')
    vim.cmd('Explore ' .. current_file)
end

M.openExplorer = function()
    vim.cmd('25 Lexplore')
end

M.cdToCurrent = function()
    local current_directory = vim.fn.expand("%:p")
    vim.notify(current_directory)
    vim.cmd("cd " .. current_directory)
end

map = vim.keymap.set

M.setup_navigation = function(opts)
    -- Move to window using the <ctrl> hjkl keys
    map("n", opts.left, "<C-w>h", { remap = true })
    map("n", opts.down, "<C-w>j", { remap = true })
    map("n", opts.up, "<C-w>k", { remap = true })
    map("n", opts.right, "<C-w>l", { remap = true })

    -- Move to window using the <ctrl> hjkl keys
    map("t", opts.left, "<c-\\><c-n><C-w>h", { remap = true })
    map("t", opts.down, "<c-\\><c-n><C-w>j", {  remap = true })
    map("t", opts.up, "<c-\\><c-n><C-w>k", {  remap = true })
    map("t", opts.right, "<c-\\><c-n><C-w>l", {  remap = true })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'netrw',
        callback = function()
            -- Create buffer-local keymaps
            map("n", opts.left, "<C-w>h", {  remap = true, buffer = true })
            map("n", opts.down, "<C-w>j", {  remap = true, buffer = true })
            map("n", opts.up, "<C-w>k", {  remap = true, buffer = true })
            map("n", opts.right, "<C-w>l", {  remap = true, buffer = true })
        end,
    })
end

-- Resize window using <ctrl> arrow keys
map({"n", "t"}, "<C-Up>", "<cmd>resize +2<cr>" )
map({"n", "t"}, "<C-Down>", "<cmd>resize -2<cr>" )
map({"n", "t"}, "<C-Left>", "<cmd>vertical resize -2<cr>" )
map({"n", "t"}, "<C-Right>", "<cmd>vertical resize +2<cr>" )

return M
