-- auto type in typescript (eg: const x = 1 => const x: number = 1)
-- support "heavy" type via tsc and "light" one via treesitter

local M = {}

local literal_types = {
  string = "string",
  template_string = "string",
  number = "number",
  ["true"] = "boolean",
  ["false"] = "boolean",
}

local function enclosing_variable_declarator(node)
  while node and node:type() ~= "variable_declarator" do
    node = node:parent()
  end
  return node
end

local function has_type_annotation(node)
  for child in node:iter_children() do
    if child:type() == "type_annotation" then
      return true
    end
  end
  return false
end

local function insert_type(bufnr, row, col, type)
  vim.api.nvim_buf_set_text(bufnr, row, col, row, col, vim.split(": " .. type, "\n", { plain = true }))
end

local function lsp_type(bufnr, name, row, col)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "tsc" })[1]
  if not client then
    vim.notify("TypeScript LSP is not attached", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params(0, "utf-16")
  client:request("textDocument/hover", params, function(err, result)
    local contents = result and result.contents
    local value = type(contents) == "table" and contents.value or contents
    if err or type(value) ~= "string" then
      vim.notify("Could not infer a TypeScript type here", vim.log.levels.WARN)
      return
    end

    local declaration = value:match("```[%w]*\n(.-)\n```")
    local hover_name, inferred_type
    if declaration then
      hover_name, inferred_type = declaration:match("^%s*const%s+([%a_$][%w_$]*)%s*:%s*(.+)$")
    end
    if hover_name ~= name or not inferred_type then
      vim.notify("Could not infer a TypeScript const type here", vim.log.levels.WARN)
      return
    end

    insert_type(bufnr, row, col, inferred_type)
  end, bufnr)
end

function M.add_const_type()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "typescript" and vim.bo[bufnr].filetype ~= "typescriptreact" then
    vim.notify("This command only works in TypeScript files", vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { cursor[1] - 1, cursor[2] } })
  local declarator = enclosing_variable_declarator(node)
  if not declarator or has_type_annotation(declarator) then
    vim.notify("Place the cursor on an untyped const variable", vim.log.levels.WARN)
    return
  end

  local declaration = declarator:parent()
  local name = declarator:field("name")[1]
  local value = declarator:field("value")[1]
  if not declaration or declaration:type() ~= "lexical_declaration" or not name or name:type() ~= "identifier" or not value
    or not vim.treesitter.get_node_text(declaration, bufnr):match("^%s*const%s") then
    vim.notify("Place the cursor on an untyped const variable", vim.log.levels.WARN)
    return
  end

  local name_text = vim.treesitter.get_node_text(name, bufnr)
  local _, _, _, end_col = name:range()
  local row = select(1, name:range())
  local literal_type = literal_types[value:type()]
  if literal_type then
    insert_type(bufnr, row, end_col, literal_type)
  else
    lsp_type(bufnr, name_text, row, end_col)
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>qft", M.add_const_type, { desc = "Add inferred TypeScript const type" })
end

return M
