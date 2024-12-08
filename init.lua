-- general options
local opt = vim.opt

opt.nu = true
opt.rnu = true
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 4
opt.sts = 4

local map = vim.keymap.set

map("n", '<space>p', '"+p')
map("n", '<space>y', '"+y')
map("n", '<space>Y', '"+y$')

-- generic tools: open terminal

local function openTerminal()
    vim.cmd("below terminal")
end

map("n", "<space>t", openTerminal)


-- Plugins: plugin manager

local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end

local miniDeps = require("mini.deps")
miniDeps.setup()
local add = miniDeps.add


-- plugins: dependencies for lsp
require("mini.notify").setup()

-- Plugins: lsp

add("neovim/nvim-lspconfig")
local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gs", vim.lsp.buf.type_definition)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", ",h", vim.lsp.buf.signature_help)
  map({ "n", "v" }, ",a", vim.lsp.buf.code_action)
  map("n", "gr", vim.lsp.buf.references)
  map("n", ",r", vim.lsp.buf.rename)

  map("n", ",d", vim.diagnostic.open_float)
  map("n", ",s", vim.lsp.buf.workspace_symbol)

  map("n", ",wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end)

  -- map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  -- map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

end

local servers = { "html", "cssls", --"rust_analyzer", 
    "pyright", "lua_ls", "clangd" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
  }
end

--plugins: edition tricks

require("mini.surround").setup({
    mappings = {
      add = 'ys', -- Add surrounding in Normal and Visual modes
      delete = 'ds', -- Delete surrounding
    },
})
require("mini.bracketed").setup()
require("mini.ai").setup()

-- plugins: navigating files
local file_navigation = require("file_navigation")


map("n", "<space>e", file_navigation.openExplorer)
map('n', '<space>u', file_navigation.openCurrentDir)
map('n', '<space>d', file_navigation.cdToCurrent)

local setup_navigation = function(opts)
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

setup_navigation(
{
    left = "<C-h>",
    right = "<C-l>",
    up = "<C-k>",
    down = "<C-j>",
})




-- plugins: send to term
local send_to_term = require("send_to_term")

vim.keymap.set('n', 'ss', function() send_to_term.send('direct', vim.fn.getline('.')) end, {silent = true})
vim.keymap.set('n', 's<Enter>', function() send_to_term.send('direct', "") end)
vim.keymap.set('n', 's', function()
    vim.o.operatorfunc = 'v:lua.send_to_term'
    return 'g@'
end, {expr = true, silent = true})
vim.keymap.set('v', 's', function() send_to_term.send(vim.fn.visualmode()) end, {silent = true})
vim.keymap.set('n', 'S', 's$', {silent = true})


-- plugins: git
require("mini.git").setup()

-- plugins: code assistant
add({
  source = 'yetone/avante.nvim',
  monitor = 'main',
  depends = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'echasnovski/mini.icons'
  },
  hooks = { post_checkout = function() vim.cmd('make') end }
})

require('avante_lib').load()
require('avante').setup()


-- plugins: other

add("NStefan002/speedtyper.nvim")
require("speedtyper")
