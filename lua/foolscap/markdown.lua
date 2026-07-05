-- Sanfte Markdown-Optik für den Prosa-Modus: Text bleibt echtes Markdown,
-- bekommt aber sichtbare Struktur für Überschriften, Fett, Kursiv und Zitate.
local M = {}

local ns = vim.api.nvim_create_namespace("foolscap_markdown")

local markdown_filetypes = {
  markdown = true,
  ["markdown.pandoc"] = true,
  vimwiki = true,
}

function M.is_markdown(buf)
  buf = buf or 0
  if markdown_filetypes[vim.bo[buf].filetype] == true then return true end
  local name = vim.api.nvim_buf_get_name(buf):lower()
  return name:match("%.md$") ~= nil or name:match("%.markdown$") ~= nil
end

-- Sichtbarer Grund-Look, der IN JEDEM Terminal funktioniert – auch ohne Theme
-- und ohne 'termguicolors': inverse Video (reverse) braucht keine konkreten
-- Farben und ist immer deutlich sichtbar. Wird ein Theme (z.B. wp51) angewandt,
-- überschreibt es diese Vorgaben mit seinen eigenen Farben; 'default = true'
-- sorgt dafür, dass das Theme (nicht-default) immer gewinnt – egal in welcher
-- Reihenfolge die beiden aufgerufen werden.
function M.ensure_highlights()
  local hl = vim.api.nvim_set_hl
  hl(0, "FoolscapMarkdownH1", { default = true, reverse = true, bold = true })
  hl(0, "FoolscapMarkdownH2", { default = true, bold = true, underline = true })
  hl(0, "FoolscapMarkdownH3", { default = true, bold = true })
  hl(0, "FoolscapMarkdownBold", { default = true, reverse = true, bold = true })
  hl(0, "FoolscapMarkdownBoldMarker", { default = true })
  hl(0, "FoolscapMarkdownItalic", { default = true, italic = true })
  hl(0, "FoolscapMarkdownQuote", { default = true, italic = true })
  hl(0, "FoolscapMarkdownCode", { default = true, reverse = true })
end

local function add_range(buf, row, from, to, group)
  if from and to and to > from then
    vim.api.nvim_buf_set_extmark(buf, ns, row, from, {
      end_col = to,
      hl_group = group,
      priority = 200,
    })
  end
end

local function mark_delimited(buf, row, line, marker, inner_group, marker_group)
  local start = 1
  while true do
    local a, b = line:find(marker, start, true)
    if not a then return end
    local c, d = line:find(marker, b + 1, true)
    if not c then return end
    add_range(buf, row, a - 1, b, marker_group)
    add_range(buf, row, b, c - 1, inner_group)
    add_range(buf, row, c - 1, d, marker_group)
    start = d + 1
  end
end

local function refresh(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if not M.is_markdown(buf) then return end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for row, line in ipairs(lines) do
    local i = row - 1
    if line:match("^#%s") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownH1")
    elseif line:match("^##%s") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownH2")
    elseif line:match("^###%s") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownH3")
    elseif line:match("^>") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownQuote")
    end

    mark_delimited(buf, i, line, "**", "FoolscapMarkdownBold", "FoolscapMarkdownBoldMarker")
    mark_delimited(buf, i, line, "`", "FoolscapMarkdownCode", "FoolscapMarkdownCode")
  end
end

function M.enable(win, buf)
  win = win or vim.api.nvim_get_current_win()
  buf = buf or vim.api.nvim_win_get_buf(win)
  if not M.is_markdown(buf) or vim.b[buf].foolscap_markdown_visuals then return end

  M.ensure_highlights()
  vim.b[buf].foolscap_markdown_visuals = true
  local grp = vim.api.nvim_create_augroup("FoolscapMarkdown_" .. buf, { clear = true })
  vim.b[buf].foolscap_markdown_grp = grp
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter" }, {
    group = grp,
    buffer = buf,
    callback = function() refresh(buf) end,
  })
  -- Falls später ein Colorscheme geladen wird (das alle Highlights leert),
  -- den sichtbaren Grund-Look wiederherstellen. Die Extmarks selbst überleben
  -- einen Colorscheme-Wechsel, verweisen aber auf die Gruppen-Namen.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = grp,
    callback = function() M.ensure_highlights() end,
  })
  refresh(buf)
end

function M.disable(_, buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local grp = vim.b[buf].foolscap_markdown_grp
  if grp then pcall(vim.api.nvim_del_augroup_by_id, grp) end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.b[buf].foolscap_markdown_grp = nil
  vim.b[buf].foolscap_markdown_visuals = false
end

return M
