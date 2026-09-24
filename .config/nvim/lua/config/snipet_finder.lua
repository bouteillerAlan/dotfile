local M = {}

---Locate the installed and personal snippet collections.
---@return string[] roots Directories containing package.json snippet manifests.
local function snippet_roots()
  local roots = {}
  local personal = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets")
  if vim.fn.filereadable(vim.fs.joinpath(personal, "package.json")) == 1 then
    table.insert(roots, personal)
  end
  local global = vim.api.nvim_get_runtime_file("snippets/global.json", false)[1]
  if global then table.insert(roots, vim.fs.dirname(vim.fs.dirname(global))) end
  return roots
end

---Load snippets available to Blink for the current buffer filetype.
---@return table[] entries Normalized snippets suitable for a Telescope finder.
local function snippets()
  local current_filetype = vim.bo.filetype
  local results = {}
  for _, root in ipairs(snippet_roots()) do
    local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
    if ok then
      for _, source in ipairs(package.contributes.snippets or {}) do
        local languages = type(source.language) == "table" and source.language or { source.language }
        -- Match Blink's defaults: snippets for this filetype plus those registered as `all`.
        local is_relevant = vim.tbl_contains(languages, current_filetype) or vim.tbl_contains(languages, "all")
        local ok_file, definitions = false, nil
        if is_relevant then
          ok_file, definitions = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/" .. source.path), "\n"))
        end
        if ok_file then
          local filetypes = table.concat(languages, ", ")
          for name, snippet in pairs(definitions) do
            local body = type(snippet.body) == "table" and table.concat(snippet.body, "\n") or snippet.body or ""
            local prefixes = type(snippet.prefix) == "table" and table.concat(snippet.prefix, ", ") or snippet.prefix or ""
            local description = type(snippet.description) == "table" and table.concat(snippet.description, " ") or snippet.description or ""
            -- `search` is deliberately comprehensive: Telescope's fzf sorter
            -- matches the name, trigger, description, filetype, and full body.
            table.insert(results, {
              name = name,
              prefix = prefixes,
              description = description,
              filetypes = filetypes,
              body = body,
              search = table.concat({ name, prefixes, description, filetypes or "", body }, " "),
            })
          end
        end
      end
    end
  end
  return results
end

---Open a Telescope picker that searches and inserts friendly-snippets entries.
---@return nil
function M.open()
  local filetype = vim.bo.filetype
  local entries = snippets()
  if #entries == 0 then return end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local has_fzf, fzf = pcall(function() return require("telescope").extensions.fzf end)
  -- fzf-native requires an explicit case mode; its defaults table is only
  -- merged when Telescope configures the extension, not when called directly.
  local sorter = has_fzf and fzf.native_fzf_sorter({ case_mode = "smart_case" }) or conf.generic_sorter({})

  pickers.new({}, {
    prompt_title = "Friendly Snippets",
    finder = finders.new_table({
      results = entries,
      ---Convert a normalized snippet to Telescope's entry format.
      ---@param item table Normalized snippet returned by `snippets`.
      ---@return table entry Telescope entry with searchable text in `ordinal`.
      entry_maker = function(item)
        return {
          value = item,
          ordinal = item.search,
          -- Telescope result rows must be single-line; some descriptions include example code.
          display = string.format("%s  [%s]  %s", item.name, item.prefix, item.description:gsub("[\r\n]+", " ")),
        }
      end,
    }),
    sorter = sorter,
    previewer = previewers.new_buffer_previewer({
      title = "Snippet body",
      ---Render the selected snippet body in Telescope's preview buffer.
      ---@param self table Telescope previewer instance.
      ---@param entry table Selected Telescope entry.
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.body, "\n", { plain = true }))
        -- Use the active buffer's language so snippets receive normal syntax/Tree-sitter highlighting.
        vim.bo[self.state.bufnr].filetype = filetype
        local language = vim.treesitter.language.get_lang(filetype) or filetype
        pcall(vim.treesitter.start, self.state.bufnr, language)
      end,
    }),
    ---Replace Telescope's default selection action with native snippet expansion.
    ---@param prompt_bufnr integer Telescope prompt buffer number.
    ---@return boolean keep_mappings Whether Telescope should retain these mappings.
    attach_mappings = function(prompt_bufnr)
      ---Insert the selected body and preserve its jumpable placeholders.
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        -- Start insert mode before using Neovim's native snippet engine, so
        -- placeholders remain jumpable just as they are in blink.cmp.
        vim.schedule(function()
          -- Closing Telescope is asynchronous, so wait before entering insert mode.
          vim.api.nvim_feedkeys("a", "n", false)
          vim.schedule(function() vim.snippet.expand(entry.value.body) end)
        end)
      end)
      return true
    end,
  }):find()
end

---Register the normal-mode mapping for the snippet finder.
---@return nil
function M.setup()
  vim.keymap.set("n", "<leader>fs", M.open, { desc = "Find friendly snippet" })
end

return M
