local M = {}

local function selected_json(command)
  local start_line = command.line1 - 1
  local end_line = command.line2 - 1
  local visual_mode = vim.fn.visualmode()
  local start_mark = vim.api.nvim_buf_get_mark(0, "<")
  local end_mark = vim.api.nvim_buf_get_mark(0, ">")

  if command.range > 0 and visual_mode == "v" and start_mark[1] == start_line and end_mark[1] == end_line then
    return table.concat(vim.api.nvim_buf_get_text(0, start_line, start_mark[2], end_line, end_mark[2] + 1, {}), "\n")
  end

  return table.concat(vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false), "\n")
end

local function open_prettified_json(json)
  vim.cmd("botright vsplit")

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buffer)
  vim.api.nvim_buf_set_name(buffer, "JSON pretty")
  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].filetype = "json"
  vim.bo[buffer].swapfile = false
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(json, "\n", { plain = true, trimempty = true }))
  vim.bo[buffer].modifiable = false
end

local function pretty_json(command)
  local result = vim.system({ "jq", "." }, { text = true, stdin = selected_json(command) }):wait()

  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  open_prettified_json(result.stdout)
end

function M.setup()
  vim.api.nvim_create_user_command("JsonPretty", pretty_json, {
    desc = "Pretty-print JSON in a vertical scratch buffer",
    range = true,
  })

  vim.keymap.set({ "n", "x" }, "<leader>jq", function()
    local start_mark = vim.api.nvim_buf_get_mark(0, "<")
    local end_mark = vim.api.nvim_buf_get_mark(0, ">")
    pretty_json({ line1 = start_mark[1], line2 = end_mark[1], range = 1 })
  end, { desc = "Pretty-print last JSON selection" })
end

return M
