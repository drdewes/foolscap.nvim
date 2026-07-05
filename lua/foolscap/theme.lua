-- Monochrome Schreib-Themen (Bernstein/Grün/Papier) – wie alte Terminals & Schreibmaschinen.
local M = {}

local palettes = {
  amber = { bg = "#000000", fg = "#ffb000", dim = "#7a5400", accent = "#ffd070", dark = true },
  green = { bg = "#001400", fg = "#33ff66", dim = "#1f7a3f", accent = "#aaffaa", dark = true },
  paper = { bg = "#f4ecd8", fg = "#33312b", dim = "#9a9484", accent = "#8a5a2a", dark = false },
  -- WordPerfect 5.1: blauer DOS-Textmodus-Screen, weißer Text.
  wp51 = { bg = "#0000aa", fg = "#ffffff", dim = "#9a9ad6", accent = "#ffff55", dark = true },
  -- MS Word 5.5 (DOS-Textmodus): schwarzer Screen, helles DOS-Grau.
  word55 = { bg = "#000000", fg = "#aaaaaa", dim = "#555555", accent = "#ffffff", dark = true },
}

local saved = nil

function M.apply(name)
  local p = palettes[name]
  if not p then return end
  if not saved then
    saved = {
      bg = vim.o.background,
      tgc = vim.o.termguicolors,
      syntax = vim.g.syntax_on,
      colors_name = vim.g.colors_name,
    }
  end
  vim.o.termguicolors = true
  vim.o.background = p.dark and "dark" or "light"
  vim.cmd("syntax off") -- monochrom: keine bunte Hervorhebung

  local hl = vim.api.nvim_set_hl
  for _, g in ipairs({
    "Normal", "NormalNC", "NormalFloat", "Identifier", "Statement", "Constant",
    "PreProc", "Type", "Special", "Function", "String", "Number", "Operator",
    "Delimiter", "Title", "Directory", "MoreMsg", "Question",
  }) do
    hl(0, g, { fg = p.fg, bg = p.bg })
  end
  hl(0, "Comment", { fg = p.dim, bg = p.bg, italic = true })
  hl(0, "NonText", { fg = p.bg, bg = p.bg })
  hl(0, "EndOfBuffer", { fg = p.bg, bg = p.bg })
  hl(0, "VertSplit", { fg = p.bg, bg = p.bg })
  hl(0, "WinSeparator", { fg = p.bg, bg = p.bg })
  hl(0, "LineNr", { fg = p.bg, bg = p.bg })
  hl(0, "SignColumn", { fg = p.fg, bg = p.bg })
  hl(0, "StatusLine", { fg = p.dim, bg = p.bg })
  hl(0, "StatusLineNC", { fg = p.dim, bg = p.bg })
  hl(0, "ColorColumn", { bg = p.bg })
  hl(0, "CursorLine", { bg = p.bg })
  hl(0, "Cursor", { fg = p.bg, bg = p.fg })
  hl(0, "Visual", { fg = p.bg, bg = p.fg })
  hl(0, "MatchParen", { fg = p.accent, bg = p.bg, bold = true })
  hl(0, "Pmenu", { fg = p.fg, bg = p.dim })
  hl(0, "PmenuSel", { fg = p.bg, bg = p.fg })
  -- Rechtschreibung/Grammatik bleiben sichtbar (gewellt, in Akzentfarbe):
  hl(0, "SpellBad", { sp = p.accent, undercurl = true })
  hl(0, "SpellCap", { sp = p.accent, undercurl = true })
  hl(0, "SpellRare", { sp = p.accent, undercurl = true })
  hl(0, "SpellLocal", { sp = p.accent, undercurl = true })
  -- Markdown-Struktur im Schreibmodus: echtes Markdown bleibt sichtbar.
  -- WordPerfect-/DOS-Look: vor allem Textattribute (fett, unterstrichen,
  -- invers), sparsam Farbe – jedes Element trägt eine eigene Signatur, damit
  -- sich Überschriften und Betonungen klar unterscheiden.
  --   # H1  -> Akzentfarbe, fett, DOPPELT unterstrichen
  --   ## H2 -> Akzentfarbe, fett, einfach unterstrichen
  --   ### H3-> Akzentfarbe, fett
  --   **fett** -> normale Schriftfarbe, nur fett (Schriftschnitt)
  --   *kursiv* -> kursiv + unterstrichen (wie WP Betonung zeigte)
  --   `code`   -> invers (Vorder-/Hintergrund getauscht)
  --   > Zitat  -> gedimmt, kursiv
  hl(0, "FoolscapMarkdownH1", { fg = p.accent, bg = p.bg, bold = true, underdouble = true })
  hl(0, "FoolscapMarkdownH2", { fg = p.accent, bg = p.bg, bold = true, underline = true })
  hl(0, "FoolscapMarkdownH3", { fg = p.accent, bg = p.bg, bold = true })
  hl(0, "FoolscapMarkdownBold", { fg = p.fg, bg = p.bg, bold = true })
  hl(0, "FoolscapMarkdownBoldMarker", { fg = p.dim, bg = p.bg })
  hl(0, "FoolscapMarkdownItalic", { fg = p.fg, bg = p.bg, italic = true, underline = true })
  hl(0, "FoolscapMarkdownQuote", { fg = p.dim, bg = p.bg, italic = true })
  hl(0, "FoolscapMarkdownCode", { fg = p.bg, bg = p.fg })
  M.active = name
end

function M.restore()
  if not saved then return end
  vim.o.background = saved.bg
  vim.o.termguicolors = saved.tgc
  if saved.colors_name and saved.colors_name ~= "" then
    pcall(vim.cmd.colorscheme, saved.colors_name)
  elseif saved.syntax then
    vim.cmd("syntax on")
  end
  saved = nil
  M.active = nil
end

M.palettes = palettes
return M
