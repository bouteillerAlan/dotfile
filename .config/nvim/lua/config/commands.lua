local M = {}

function M.setup()
---               ---
-- Custom function --
---               ---

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

--
-- floating terminal
--
local term_augroup = vim.api.nvim_create_augroup("TerminalToggle", { clear = true })

-- open a new window with a terminal in it
local function toggle_terminal()
  -- create buffer if it doesn't exist
  if not vim.g.term_buf or not vim.api.nvim_buf_is_valid(vim.g.term_buf) then
    vim.g.term_buf = vim.api.nvim_create_buf(false, true)
    vim.g.term_job = nil
  end

  -- check if window is already open
  if vim.g.term_win and vim.api.nvim_win_is_valid(vim.g.term_win) then
    vim.api.nvim_win_hide(vim.g.term_win)
    vim.g.term_win = nil
  else
    -- calculate window size
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- open floating window with the terminal buffer
    vim.g.term_win = vim.api.nvim_open_win(vim.g.term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      border = "rounded",
      style = "minimal",
    })

    -- prevent any other buffer to be open in the window
    -- this is mendatory, because if not set we could lost
    -- any term open and see it replace by a new buffer
    -- vim.api.nvim_set_option_value('winfixbuf', true, { win = vim.g.term_win })

    -- auto-close terminal window on buffer leave
    vim.api.nvim_create_autocmd("BufLeave", {
      group = term_augroup,
      buffer = vim.g.term_buf,
      callback = function()
        if vim.g.term_win and vim.api.nvim_win_is_valid(vim.g.term_win) then
          vim.api.nvim_win_hide(vim.g.term_win)
          vim.g.term_win = nil
        end
      end,
    })

    -- start terminal if not already started
    if not vim.g.term_job then
      vim.g.term_job = vim.fn.jobstart(vim.o.shell, {
        term = true,
        pty = true,
      })
    end

    vim.cmd("startinsert")
  end
end

vim.keymap.set({"n"}, "<leader>tt", toggle_terminal, { desc = "Toggle a floating terminal" })
-- exit terminal mode
vim.keymap.set({"t"}, "<leader><esc>", "<c-\\><c-n>")



-- overseer custom action for bash
local overseer = require("overseer")

overseer.register_template({
  name = "watch script",
  params = {
    script = { type = "string" },
  },
  builder = function(params)
    local script = vim.fn.getcwd() .. "/" .. params.script

    return {
      name = "watch: " .. params.script,
      cmd = "watchexec",
      args = { "-c", "-r", "-w", vim.fn.getcwd(), "--", script },
      components = { "default" },
    }
  end,
})

local function ensure_watch_task()
  vim.ui.input({ prompt = "Script to watch: ", default = "./" }, function(input)
    if not input or input == "" then
      return
    end

    local script_name = input:gsub("^%./", "")

    local task_name = "watch: " .. script_name

    local tasks = overseer.list_tasks({ name = task_name })
    if #tasks > 0 then
      overseer.run_action(tasks[1], "open vsplit")
      vim.cmd("wincmd h")
      return
    end

    overseer.run_template(
      { name = "watch script", params = { script = script_name } },
      function(task)
        if task then
          overseer.run_action(task, "open vsplit")
          vim.cmd("wincmd h")
        end
      end
    )
  end)
end

vim.keymap.set("n", "<leader>rw", ensure_watch_task, { desc = "Start/focus watch script (prompt)" })

end

return M
