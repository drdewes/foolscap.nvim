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

-- H1 hervorheben UND zentrieren in EINEM Extmark. Das Highlight (inkl.
-- Doppel-Unterstreichung) und das linke inline-Polster müssen zusammengehören:
-- zwei getrennte Extmarks an Spalte 0 kollidieren, dann rendert die
-- Unterstreichung versetzt zum Text (statt darunter). Die reale Zeile (inkl.
-- "# ") bleibt unverändert – das Polster ist nur virtueller Leerraum.
-- Wie eine zentrierte Überschrift in WordPerfect.
local function center_h1(buf, row, line)
  local width = require("foolscap.config").options.width or 65
  local pad = math.floor((width - vim.fn.strdisplaywidth(line)) / 2)
  local opts = {
    end_col = #line,
    hl_group = "FoolscapMarkdownH1",
    priority = 200,
  }
  if pad >= 1 then
    opts.virt_text = { { string.rep(" ", pad) } }
    opts.virt_text_pos = "inline"
  end
  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, opts)
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

-- Einzelnes *kursiv* markieren – aber **fett** NICHT anfassen. Deshalb ein
-- eigener Scanner statt mark_delimited: Doppelsterne (**) werden übersprungen,
-- nur einzeln stehende Sterne bilden ein Kursiv-Paar. (` * ` als Rechenzeichen
-- ohne Partner bleibt unmarkiert.)
local function mark_italic(buf, row, line)
  local n = #line
  local i = 1
  local open = nil
  while i <= n do
    if line:sub(i, i) == "*" then
      if line:sub(i + 1, i + 1) == "*" then
        i = i + 2 -- ** überspringen (Fett)
      else
        if open then
          add_range(buf, row, open - 1, open, "FoolscapMarkdownBoldMarker") -- öffnendes *
          add_range(buf, row, open, i - 1, "FoolscapMarkdownItalic")        -- Inhalt
          add_range(buf, row, i - 1, i, "FoolscapMarkdownBoldMarker")       -- schließendes *
          open = nil
        else
          open = i
        end
        i = i + 1
      end
    else
      i = i + 1
    end
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
      center_h1(buf, i, line) -- H1 hervorheben + zentrieren (ein Extmark)
    elseif line:match("^##%s") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownH2")
    elseif line:match("^###%s") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownH3")
    elseif line:match("^>") then
      add_range(buf, i, 0, #line, "FoolscapMarkdownQuote")
    end

    mark_delimited(buf, i, line, "**", "FoolscapMarkdownBold", "FoolscapMarkdownBoldMarker")
    mark_italic(buf, i, line)
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
