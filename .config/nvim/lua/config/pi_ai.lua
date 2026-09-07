local M = {}

local pi_job = nil
local pi_busy = false
local stdout_buffer = ""
local pi_output = {}
local replace_target = nil
local current_usage = nil
local current_project_root = nil
local current_request_mode = nil
local current_question = nil
local current_selected_text = nil
local ask_output_bufnr = nil
local ask_output_win = nil
local stopping_pi = false

-- Persistent right-side interactive `pi` chat session (separate from the
-- one-shot RPC job above).
local pi_chat_buf = nil
local pi_chat_win = nil
local pi_chat_job = nil
local pi_chat_root = nil

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
    return "usage not available"
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
  notify(prefix .. " - " .. format_usage(), level or vim.log.levels.INFO)
end

local function ensure_ask_window()
  if ask_output_bufnr and vim.api.nvim_buf_is_valid(ask_output_bufnr) then
    return ask_output_bufnr
  end

  ask_output_bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[ask_output_bufnr].buftype = "nofile"
  vim.bo[ask_output_bufnr].bufhidden = "hide"
  vim.bo[ask_output_bufnr].swapfile = false
  vim.bo[ask_output_bufnr].filetype = "markdown"
  vim.bo[ask_output_bufnr].modifiable = true

  return ask_output_bufnr
end

local function normalize_lines(items)
  local lines = {}

  for _, item in ipairs(items) do
    local chunks = vim.split(tostring(item), "\n", { plain = true })
    for _, chunk in ipairs(chunks) do
      table.insert(lines, chunk)
    end
  end

  return lines
end

local function show_ask_output(lines)
  local bufnr = ensure_ask_window()
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, normalize_lines(lines))
  vim.bo[bufnr].modifiable = false

  if ask_output_win and vim.api.nvim_win_is_valid(ask_output_win) then
    return
  end

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  ask_output_win = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Pi Ask ",
    title_pos = "center",
  })
end

local function render_ask_response(answer, status)
  local lines = {
    "# Pi Ask",
    "",
    "**Question:**",
    current_question or "",
  }

  if current_request_mode == "ask" and current_selected_text and current_selected_text ~= "" then
    vim.list_extend(lines, { "", "**Selected text:**", "```text", current_selected_text, "```" })
  end

  vim.list_extend(lines, { "", "**Status:**", status or "" })

  if answer and answer ~= "" then
    vim.list_extend(lines, { "", "**Answer:**", answer })
  end

  show_ask_output(lines)
end

local function usage_has_tokens(usage)
  return type(usage) == "table"
    and ((usage.input or 0) > 0
      or (usage.output or 0) > 0
      or (usage.cacheRead or 0) > 0
      or (usage.cacheWrite or 0) > 0
      or (usage.totalTokens or 0) > 0)
end

local function update_usage(usage)
  if type(usage) ~= "table" then
    return
  end

  -- Some providers/RPC streams emit zero usage during streaming and only put
  -- the authoritative accounting on message_end/turn_end.message. Keep the
  -- last non-zero usage so the final notification is not "0 0 0".
  if not current_usage or usage_has_tokens(usage) or not usage_has_tokens(current_usage) then
    current_usage = usage
  end
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

local function get_visual_selection_text()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if start_pos[2] ~= 0 and end_pos[2] ~= 0 then
    local start_line = start_pos[2] - 1
    local start_col = math.max(start_pos[3] - 1, 0)
    local end_line = end_pos[2] - 1
    local end_col = math.max(end_pos[3], 0)
    local ok, text = pcall(vim.api.nvim_buf_get_text, bufnr, start_line, start_col, end_line, end_col, {})

    if ok and text and #text > 0 then
      local joined = table.concat(text, "\n")
      if joined:gsub("%s+", "") ~= "" then
        return joined
      end
    end
  end

  local reg = "z"
  local saved = vim.fn.getreginfo(reg)
  local ok = pcall(vim.cmd, 'silent normal! gv"' .. reg .. 'y')
  local text = ok and vim.fn.getreg(reg) or ""

  if saved and saved.regcontents then
    pcall(vim.fn.setreg, reg, saved.regcontents, saved.regtype)
  end

  if text == "" or text:gsub("%s+", "") == "" then
    return nil
  end

  return text
end

local function pi_chat_job_alive()
  return pi_chat_job ~= nil and vim.fn.jobwait({ pi_chat_job }, 0)[1] == -1
end

local function open_pi_chat_window()
  if pi_chat_win and vim.api.nvim_win_is_valid(pi_chat_win) then
    vim.api.nvim_set_current_win(pi_chat_win)
    return
  end

  if not pi_chat_buf or not vim.api.nvim_buf_is_valid(pi_chat_buf) then
    pi_chat_buf = vim.api.nvim_create_buf(false, true)
  end

  -- Top-level split anchored to the right edge of the whole editor, not
  -- just the current window.
  pi_chat_win = vim.api.nvim_open_win(pi_chat_buf, true, {
    split = "right",
    win = -1,
    width = math.floor(vim.o.columns * 0.4),
  })
end

-- Ensures a right-side window with a live interactive `pi` session exists,
-- rooted at `project_root`. Returns false (and notifies) if the job could
-- not be started.
local function ensure_pi_chat(project_root)
  if pi_chat_root and pi_chat_root ~= project_root and pi_chat_job_alive() then
    -- A fresh process means a fresh conversation context, same as the RPC path.
    vim.fn.jobstop(pi_chat_job)
    pi_chat_job = nil
    pi_chat_buf = nil
    notify("pi chat: new project detected, restarting session", vim.log.levels.INFO)
  end

  open_pi_chat_window()

  if not pi_chat_job_alive() then
    pi_chat_root = project_root

    -- `term = true` attaches the pty to whatever buffer is current right
    -- now, so it must run after open_pi_chat_window() made it current.
    pi_chat_job = vim.fn.jobstart({ "pi" }, {
      term = true,
      cwd = project_root,
      on_exit = function()
        pi_chat_job = nil
      end,
    })

    if pi_chat_job <= 0 then
      pi_chat_job = nil
      notify("pi chat: impossible to start `pi`", vim.log.levels.ERROR)
      return false
    end
  end

  return true
end

local function send_to_pi_chat(text)
  -- Wrap in a bracketed paste so the multi-line message (file path,
  -- selection, question) lands as one pasted block in pi's input box
  -- instead of submitting on every embedded newline, then send Enter.
  vim.fn.chansend(pi_chat_job, "\27[200~" .. text .. "\27[201~")
  vim.fn.chansend(pi_chat_job, "\r")
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
    return "Complete, fix or rewrite the selected code."
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

local function finish_request()
  pi_busy = false
  stop_loader()

  local text = table.concat(pi_output, "")
  text = text:gsub("%s+$", "")

  if current_request_mode == "ask" then
    if text == "" then
      text = "(empty response)"
    end

    render_ask_response(text, "Done")
    notify_usage("pi: answer ready", vim.log.levels.INFO)
  elseif replace_target then
    text = strip_markdown_fence(text)

    if text == "" then
      notify("pi: empty answer", vim.log.levels.WARN)
      pi_output = {}
      replace_target = nil
      current_usage = nil
      current_request_mode = nil
      current_question = nil
      current_selected_text = nil
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

    notify_usage("pi: code replaced", vim.log.levels.INFO)
  end

  pi_output = {}
  replace_target = nil
  current_usage = nil
  current_request_mode = nil
  current_question = nil
  current_selected_text = nil
end

local function handle_rpc_line(line)
  if line == "" then
    return
  end

  local ok, event = pcall(vim.json.decode, line)
  if not ok then
    notify("pi: invalid JSON: " .. line, vim.log.levels.WARN)
    return
  end

  update_usage(event.usage)
  update_usage(event.message and event.message.usage)

  if event.type == "message_update" then
    local delta = event.assistantMessageEvent
    if delta and delta.type == "text_delta" then
      table.insert(pi_output, delta.delta)
      if current_request_mode == "ask" then
        local partial = table.concat(pi_output, "")
        vim.schedule(function()
          render_ask_response(partial, "Streaming...")
        end)
      end
    end
  elseif event.type == "message_end" or event.type == "turn_end" then
    update_usage(event.message and event.message.usage)
  elseif event.type == "agent_settled" then
    vim.schedule(finish_request)
  elseif event.type == "response" and event.success == false then
    pi_busy = false
    stop_loader()
    notify_usage("pi: command denied", vim.log.levels.ERROR)
    current_usage = nil
    if current_request_mode == "ask" then
      render_ask_response("(command denied)", "Error")
    end
    current_request_mode = nil
    current_question = nil
    current_selected_text = nil
  elseif event.type == "extension_error" then
    notify("pi: extension error", vim.log.levels.ERROR)
    if current_request_mode == "ask" then
      render_ask_response("(extension error)", "Error")
    end
    current_request_mode = nil
    current_question = nil
    current_selected_text = nil
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
      local request_mode = current_request_mode
      local question = current_question
      stopping_pi = false
      pi_job = nil
      pi_busy = false
      stdout_buffer = ""
      pi_output = {}
      replace_target = nil
      current_usage = nil
      current_request_mode = nil
      current_question = nil
      current_selected_text = nil
      stop_loader()
      if code ~= 0 and not was_stopping_pi then
        notify("pi: process ended with code " .. tostring(code), vim.log.levels.ERROR)
        if request_mode == "ask" then
          current_question = question
          render_ask_response("(process ended unexpectedly)", "Error")
          current_question = nil
        end
      end
    end,
  })

  if pi_job <= 0 then
    pi_job = nil
    notify("pi: impossible to start `pi --mode rpc`", vim.log.levels.ERROR)
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
  notify_usage("pi: generation aborted", vim.log.levels.WARN)
  current_usage = nil

  if current_request_mode == "ask" then
    render_ask_response("(aborted)", "Aborted")
  end

  current_request_mode = nil
  current_question = nil
  current_selected_text = nil
  return true
end

function M.abort_or_nohlsearch()
  if not M.abort() then
    vim.cmd("nohlsearch")
  end
end

function M.super_ai(opts)
  if pi_busy then
    notify("pi is already working; hit Esc to abort", vim.log.levels.WARN)
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
    notify("pi: empty selection", vim.log.levels.WARN)
    return
  end

  local instruction = extract_pi_instruction(selected_code)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local project_root = project_root_for_file(filename)
  local filetype = vim.bo[bufnr].filetype

  if current_project_root and current_project_root ~= project_root then
    stop_pi_process()
    notify("pi: new project detected: context reset", vim.log.levels.INFO)
  end
  current_project_root = project_root

  local prompt = [[
You are integrated into Neovim via pi RPC.

File: ]] .. filename .. [[
Language: ]] .. filetype .. [[

User instruction extracted from the `pi:` comment:
]] .. instruction .. [[

Rules:
- Reply only with the final code that should replace the selection.
- No markdown.
- No explanation.
- No code fences.
- `pi:` comments are instructions: do not copy them into the final code unless explicitly asked.

Selected code:

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
    notify("pi: generation started; Esc to abort", vim.log.levels.INFO)
  else
    pi_busy = false
    pi_output = {}
    replace_target = nil
    current_usage = nil
    stop_loader()
  end
end

local function ask_with_question(question, opts)
  if question == nil or question:gsub("%s+", "") == "" then
    notify("pi: empty question", vim.log.levels.WARN)
    return
  end

  if pi_busy then
    notify("pi is already working; hit Esc to abort", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local project_root = project_root_for_file(filename)
  local filetype = vim.bo[bufnr].filetype
  local selected_text = opts and opts.selected_text or nil

  if current_project_root and current_project_root ~= project_root then
    stop_pi_process()
    notify("pi: new project detected: context reset", vim.log.levels.INFO)
  end
  current_project_root = project_root

  local prompt = [[
You are integrated into Neovim via pi RPC.

File: ]] .. filename .. [[
Language: ]] .. filetype .. [[

User question:
]] .. question .. [[
]]

  if selected_text and selected_text ~= "" then
    prompt = prompt .. [[
Selected text:
```text
]] .. selected_text .. [[
```
]]
  end

  prompt = prompt .. [[
Rules:
- Answer clearly and directly.
- Use markdown only if it is helpful.
- Do not edit any files.
- Do not output unnecessary pseudo-JSON.
]]

  pi_busy = true
  pi_output = {}
  current_usage = nil
  current_request_mode = "ask"
  current_question = question
  current_selected_text = selected_text
  replace_target = nil

  render_ask_response("Thinking...", "Waiting for response...")

  if send_rpc({ type = "prompt", message = prompt }) then
    notify("pi: question sent", vim.log.levels.INFO)
  else
    pi_busy = false
    pi_output = {}
    current_request_mode = nil
    current_question = nil
    current_selected_text = nil
    current_usage = nil
    render_ask_response("Failed to send question.")
  end
end

function M.ask(question, opts)
  if question and question ~= "" then
    ask_with_question(question, opts)
    return
  end

  vim.ui.input({ prompt = "pi ask: " }, function(input)
    if input then
      ask_with_question(input, opts)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("SuperAi", function(opts)
    M.super_ai(opts)
  end, { range = true, desc = "pi: rewrite selected/ranged code with comments pi:" })

  vim.api.nvim_create_user_command("PiAsk", function(opts)
    M.ask(table.concat(opts.fargs, " "))
  end, { nargs = "*", desc = "pi: ask a question and show the answer in a floating window" })

  vim.keymap.set({ "n", "v" }, "<leader>pia", function()
    local selected_text = get_visual_selection_text()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local project_root = project_root_for_file(filename)

    vim.ui.input({ prompt = "pi chat: " }, function(input)
      if not input or input:gsub("%s+", "") == "" then
        return
      end

      if not ensure_pi_chat(project_root) then
        return
      end

      local parts = { "File: " .. (filename ~= "" and filename or "(no file)") }

      if selected_text and selected_text ~= "" then
        vim.list_extend(parts, { "", "Selected:", "```" .. vim.bo[bufnr].filetype, selected_text, "```" })
      end

      vim.list_extend(parts, { "", input })

      send_to_pi_chat(table.concat(parts, "\n"))
      vim.cmd("startinsert")
    end)
  end, { desc = "pi chat: open right-side session with file/selection/message" })

  vim.keymap.set("v", "<leader>pi", function()
    M.super_ai()
  end, { desc = "pi SuperAi: rewrite selection" })

  vim.keymap.set("n", "<leader>pi", function()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    if start_pos[2] == 0 or end_pos[2] == 0 then
      notify("pi: no previous visual selection", vim.log.levels.WARN)
      return
    end

    M.super_ai({
      line1 = math.min(start_pos[2], end_pos[2]),
      line2 = math.max(start_pos[2], end_pos[2]),
    })
  end, { desc = "pi SuperAi: rewrite last visual selection" })

  vim.keymap.set("n", "<esc>", M.abort_or_nohlsearch, { desc = "pi abort or clear search highlight" })
end

return M
