local M = {}

local pi_job = nil
local pi_busy = false
local stdout_buffer = ""
local pi_output = {}
local replace_target = nil
local current_usage = nil
local current_project_root = nil
local stopping_pi = false

local loader_ns = vim.api.nvim_create_namespace("pi_super_ai_loader")
local loader_timer = nil
local loader = nil
local loader_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

for i, frame in ipairs(loader_frames) do
  vim.fn.sign_define("PiSuperAi" .. i, {
    text = frame,
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "",
  })
end

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO)
  end)
end

local function strip_markdown_fence(text)
  text = text:gsub("^%s*```[%w_%-]*%s*\n", "")
  text = text:gsub("\n%s*```%s*$", "")
  return text
end

local function format_number(value)
  if value == nil then
    return "?"
  end
  return tostring(value)
end

local function format_money(value)
  if type(value) ~= "number" then
    return "?"
  end
  if value == 0 then
    return "$0"
  end
  if value < 0.01 then
    return string.format("$%.6f", value)
  end
  return string.format("$%.4f", value)
end

local function format_usage()
  if not current_usage then
    return "usage indisponible"
  end

  local cost = current_usage.cost
  local total_cost = type(cost) == "table" and cost.total or nil

  return table.concat({
    "↑ " .. format_number(current_usage.input),
    "↓ " .. format_number(current_usage.output),
    "R " .. format_number(current_usage.cacheRead),
    "W " .. format_number(current_usage.cacheWrite),
    "Σ " .. format_number(current_usage.totalTokens),
    format_money(total_cost),
  }, "  ")
end

local function notify_usage(prefix, level)
  notify(prefix .. " — " .. format_usage(), level or vim.log.levels.INFO)
end

local function project_root_for_file(filename)
  -- Use the Git root to avoid leaking context between projects.
  local dir = filename ~= "" and vim.fn.fnamemodify(filename, ":p:h") or vim.fn.getcwd()
  local root = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]

  if vim.v.shell_error == 0 and root and root ~= "" then
    return root
  end

  return dir
end

local function stop_pi_process()
  -- A fresh RPC process means a fresh conversation context.
  if pi_job then
    stopping_pi = true
    vim.fn.jobstop(pi_job)
  end
  pi_job = nil
  stdout_buffer = ""
end

local function extract_pi_instruction(text)
  local instructions = {}

  for line in (text .. "\n"):gmatch("(.-)\n") do
    local instruction = line:match("^%s*[/#%-%*]+%s*pi:%s*(.+)%s*$")
      or line:match("^%s*<!%-%-%s*pi:%s*(.-)%s*%-%->%s*$")

    if instruction and instruction ~= "" then
      table.insert(instructions, instruction)
    end
  end

  if #instructions == 0 then
    return "Complète, corrige ou réécris le code sélectionné."
  end

  return table.concat(instructions, "\n")
end

local function render_loader()
  if not loader or not vim.api.nvim_buf_is_valid(loader.bufnr) then
    return
  end

  local frame = loader_frames[loader.frame]
  vim.fn.sign_place(loader.sign_id, "pi_super_ai", "PiSuperAi" .. loader.frame, loader.bufnr, {
    lnum = loader.line + 1,
    priority = 50,
  })

  vim.api.nvim_buf_clear_namespace(loader.bufnr, loader_ns, 0, -1)
  vim.api.nvim_buf_set_extmark(loader.bufnr, loader_ns, loader.line, 0, {
    virt_text = { { frame .. " pi", "DiagnosticInfo" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })

  loader.frame = (loader.frame % #loader_frames) + 1
end

local function start_loader(bufnr, line)
  if loader_timer then
    loader_timer:stop()
    loader_timer:close()
  end

  loader = {
    bufnr = bufnr,
    line = line,
    frame = 1,
    sign_id = 424242,
  }

  render_loader()

  loader_timer = vim.uv.new_timer()
  loader_timer:start(0, 120, vim.schedule_wrap(render_loader))
end

local function stop_loader()
  if loader_timer then
    loader_timer:stop()
    loader_timer:close()
    loader_timer = nil
  end

  if loader and vim.api.nvim_buf_is_valid(loader.bufnr) then
    vim.fn.sign_unplace("pi_super_ai", { buffer = loader.bufnr, id = loader.sign_id })
    vim.api.nvim_buf_clear_namespace(loader.bufnr, loader_ns, 0, -1)
  end

  loader = nil
end

local function finish_generation()
  pi_busy = false
  stop_loader()

  if not replace_target then
    pi_output = {}
    current_usage = nil
    return
  end

  local text = table.concat(pi_output, "")
  text = strip_markdown_fence(text):gsub("%s+$", "")

  if text == "" then
    notify("pi: réponse vide", vim.log.levels.WARN)
    pi_output = {}
    replace_target = nil
    current_usage = nil
    return
  end

  local lines = vim.split(text, "\n", { plain = true })

  vim.api.nvim_buf_set_lines(
    replace_target.bufnr,
    replace_target.start_line,
    replace_target.end_line,
    false,
    lines
  )

  notify_usage("pi: code remplacé", vim.log.levels.INFO)
  pi_output = {}
  replace_target = nil
  current_usage = nil
end

local function handle_rpc_line(line)
  if line == "" then
    return
  end

  local ok, event = pcall(vim.json.decode, line)
  if not ok then
    notify("pi: JSON invalide: " .. line, vim.log.levels.WARN)
    return
  end

  if event.usage then
    current_usage = event.usage
  end

  if event.type == "message_update" then
    local delta = event.assistantMessageEvent
    if delta and delta.type == "text_delta" then
      table.insert(pi_output, delta.delta)
    end
  elseif event.type == "agent_settled" then
    vim.schedule(finish_generation)
  elseif event.type == "response" and event.success == false then
    pi_busy = false
    stop_loader()
    notify_usage("pi: commande refusée", vim.log.levels.ERROR)
    current_usage = nil
  elseif event.type == "extension_error" then
    notify("pi: erreur extension", vim.log.levels.ERROR)
  end
end

local function on_stdout(_, data, _)
  if not data then
    return
  end

  for i, chunk in ipairs(data) do
    if i == 1 then
      stdout_buffer = stdout_buffer .. chunk
    else
      stdout_buffer = stdout_buffer .. "\n" .. chunk
    end
  end

  while true do
    local newline = stdout_buffer:find("\n", 1, true)
    if not newline then
      break
    end

    local line = stdout_buffer:sub(1, newline - 1)
    stdout_buffer = stdout_buffer:sub(newline + 1)

    if line:sub(-1) == "\r" then
      line = line:sub(1, -2)
    end

    handle_rpc_line(line)
  end
end

local function pi_start()
  if pi_job then
    return true
  end

  stdout_buffer = ""

  pi_job = vim.fn.jobstart({ "pi", "--mode", "rpc", "--no-session", "--no-tools" }, {
    stdin = "pipe",
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = on_stdout,
    on_stderr = function(_, data, _)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line ~= "" then
          notify("pi stderr: " .. line, vim.log.levels.WARN)
        end
      end
    end,
    on_exit = function(_, code, _)
      local was_stopping_pi = stopping_pi
      stopping_pi = false
      pi_job = nil
      pi_busy = false
      stdout_buffer = ""
      pi_output = {}
      replace_target = nil
      current_usage = nil
      stop_loader()
      if code ~= 0 and not was_stopping_pi then
        notify("pi: process terminé avec code " .. tostring(code), vim.log.levels.ERROR)
      end
    end,
  })

  if pi_job <= 0 then
    pi_job = nil
    notify("pi: impossible de démarrer `pi --mode rpc`", vim.log.levels.ERROR)
    return false
  end

  return true
end

local function send_rpc(payload)
  if not pi_start() then
    return false
  end

  vim.fn.chansend(pi_job, vim.json.encode(payload) .. "\n")
  return true
end

function M.abort()
  if not pi_job or not pi_busy then
    return false
  end

  send_rpc({ type = "abort" })
  pi_busy = false
  pi_output = {}
  replace_target = nil
  stop_loader()
  notify_usage("pi: génération annulée", vim.log.levels.WARN)
  current_usage = nil
  return true
end

function M.abort_or_nohlsearch()
  if not M.abort() then
    vim.cmd("nohlsearch")
  end
end

function M.super_ai(opts)
  if pi_busy then
    notify("pi travaille déjà; Esc pour abort", vim.log.levels.WARN)
    return
  end

  local start_line
  local end_line

  if opts and opts.line1 and opts.line2 then
    start_line = opts.line1 - 1
    end_line = opts.line2
  else
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    start_line = start_pos[2] - 1
    end_line = end_pos[2]
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  local selected_code = table.concat(lines, "\n")

  if selected_code == "" then
    notify("pi: sélection vide", vim.log.levels.WARN)
    return
  end

  local instruction = extract_pi_instruction(selected_code)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local project_root = project_root_for_file(filename)
  local filetype = vim.bo[bufnr].filetype

  if current_project_root and current_project_root ~= project_root then
    stop_pi_process()
    notify("pi: nouveau projet détecté, contexte reset", vim.log.levels.INFO)
  end
  current_project_root = project_root

  local prompt = [[
Tu es intégré dans Neovim via pi RPC.

Fichier: ]] .. filename .. [[
Langage: ]] .. filetype .. [[

Instruction utilisateur extraite des commentaires `pi:`:
]] .. instruction .. [[

Règles:
- Réponds uniquement avec le code final qui doit remplacer la sélection.
- Pas de markdown.
- Pas d'explication.
- Pas de blocs ```.
- Les commentaires `pi:` sont des instructions: ne les recopie pas dans le code final, sauf demande explicite.

Code sélectionné:

]] .. selected_code

  pi_busy = true
  pi_output = {}
  current_usage = nil
  replace_target = {
    bufnr = bufnr,
    start_line = start_line,
    end_line = end_line,
  }
  start_loader(bufnr, start_line)

  if send_rpc({ type = "prompt", message = prompt }) then
    notify("pi: génération lancée; Esc pour abort", vim.log.levels.INFO)
  else
    pi_busy = false
    pi_output = {}
    replace_target = nil
    current_usage = nil
    stop_loader()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("SuperAi", function(opts)
    M.super_ai(opts)
  end, { range = true, desc = "pi: rewrite selected/ranged code with comments pi:" })

  vim.keymap.set("v", "<leader>pi", function()
    M.super_ai()
  end, { desc = "pi SuperAi: rewrite selection" })

  vim.keymap.set("n", "<leader>pi", function()
    vim.cmd("'<,'>SuperAi")
  end, { desc = "pi SuperAi: rewrite last visual selection" })

  vim.keymap.set("n", "<esc>", M.abort_or_nohlsearch, { desc = "pi abort or clear search highlight" })
end

return M
