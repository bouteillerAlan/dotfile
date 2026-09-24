local M = {}

function M.setup()
---        ---
-- Shortcut --
---        ---
-- telescope
require('telescope').load_extension('fzf')
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", function() builtin.find_files({ hidden = true, no_ignore = true }) end, {desc = "Telescope find files"})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc = "Telescope live grep"})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {desc = "Telescope buffers"})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {desc = "Telescope help tags"})
vim.keymap.set("n", "<leader>fhs", builtin.keymaps, {desc = "Telescope keymaps"})
-- for todo list
vim.keymap.set("n", "<leader>ft", "<CMD>TodoTelescope<CR>", {desc = "Telescope todo list"})
-- for recent file
vim.keymap.set("n", "<Leader>fr", "<cmd>lua require('telescope').extensions.recent_files.pick()<CR>", {desc = "telescope recent file"})
require("config.snipet_finder").setup()

-- oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

-- cloak
vim.keymap.set("n", "<leader>hh", "<cmd>CloakToggle<cr>", { desc = "Toggle cloak" })

-- pi SuperAi integration (`:SuperAi`, visual `<leader>pi`, Esc aborts pi or clears search highlight)
require("config.pi_ai").setup()

-- todo list
vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })

-- trouble
vim.keymap.set("n", "<leader>dD", "<cmd>Trouble diagnostics toggle<cr>", {desc = "Diagnostics (Trouble)"})
vim.keymap.set("n", "<leader>dd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {desc = "Buffer Diagnostics (Trouble)"})
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle focus=true<cr>", {desc = "Symbols (Trouble)"})
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble loclist toggle<cr>", {desc = "Location List (Trouble)"})
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>", {desc = "Quickfix List (Trouble)"})
vim.keymap.set("n", "<leader>ti", "<cmd>InspectTree<cr>", { desc = "Tree-sitter inspect tree" })

-- rename
-- this one show the old value in the prompt, useful to edit it for example
vim.keymap.set("n", "<leader>rn", function() return ":IncRename " .. vim.fn.expand("<cword>") end, { expr = true })
-- vim.keymap.set("n", "<leader>rn", ":IncRename ")

-- LSP navigation with Trouble integration
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    -- enable inlay hints (inline type info, param names, return types)
    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    -- Override Vim's built-in local-declaration search with the LSP definition request.
    vim.keymap.set("n", "gd", vim.lsp.buf.definition,
      vim.tbl_extend("force", opts, { desc = "LSP Definition" }))
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded", max_width = 100, max_height = 30 })
    end, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = "LSP Declaration" }))
    vim.keymap.set("n", 'gi', function() require('trouble').toggle('lsp_implementations') end, vim.tbl_extend('force', opts, { desc = 'LSP Implementation' }))
    vim.keymap.set('n', '<leader>K', function() require('trouble').toggle('lsp_references') end, vim.tbl_extend('force', opts, { desc = 'LSP References' }))
    vim.keymap.set('n', 'gt', function() require('trouble').toggle('lsp_type_definitions') end, vim.tbl_extend('force', opts, { desc = 'LSP Type Definition' }))
    -- toggle inlay hints on/off per buffer
    vim.keymap.set('n', '<leader>ih', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, vim.tbl_extend('force', opts, { desc = 'Toggle inlay hints' }))
    -- error-only diagnostic navigation ([d/]d for all severities are neovim built-in defaults)
    vim.keymap.set("n", "]D", function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, vim.tbl_extend("force", opts, { desc = "Next error" }))
    vim.keymap.set("n", "[D", function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, vim.tbl_extend("force", opts, { desc = "Prev error" }))
    -- code action / quick fix (visual mode too for range actions e.g. extract)
    vim.keymap.set({ "n", "v" }, "<leader>qf", vim.lsp.buf.code_action,
      vim.tbl_extend("force", opts, { desc = "Code action / quick fix" }))
    vim.keymap.set("n", "<leader>qfi", function()
      vim.lsp.buf.code_action({ context = { only = { "source.addMissingImports" } }, apply = true })
    end, vim.tbl_extend("force", opts, { desc = "Add missing imports" }))
    vim.keymap.set("n", "<leader>qfa", function()
      vim.lsp.buf.code_action({ context = { only = { "source.fixAll" } }, apply = true })
    end, vim.tbl_extend("force", opts, { desc = "Fix all auto-fixable errors" }))
  end
})

-- undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- custom one
vim.keymap.set('n', '<C-z>', '<cmd>undo<cr>', {desc = 'undo one change'})

-- overseer
vim.keymap.set('n', '<leader>ot', vim.cmd.OverseerToggle, {desc = 'overseer toogle'})
vim.keymap.set('n', '<leader>or', vim.cmd.OverseerRun, {desc = 'overseer run'})


end

return M
