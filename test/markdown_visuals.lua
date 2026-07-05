-- Headless-Test für die Markdown-Optik (markdown_visuals).
--
-- Ausführen (aus dem Repo-Wurzelverzeichnis):
--   nvim --headless -u NONE \
--     --cmd "set runtimepath^=$PWD" \
--     -c "luafile test/markdown_visuals.lua"
--
-- Der Test bildet den fwp-Startpfad nach (config.setup{theme='wp51'} + room())
-- und prüft, dass:
--   1. der Prosa- und Markdown-Modus im Buffer aktiv ist,
--   2. Extmarks für Überschrift / **fett** / `code` / Zitat gesetzt werden,
--   3. die Highlight-Gruppen sichtbar definiert sind (Farbe ODER reverse).
--
-- Beendet nvim mit Exit-Code 0 bei Erfolg, 1 bei Fehler.

local fails = {}
local function check(name, cond)
  if cond then
    io.stderr:write("  ok   " .. name .. "\n")
  else
    io.stderr:write("  FAIL " .. name .. "\n")
    fails[#fails + 1] = name
  end
end

-- Testdatei anlegen (als .md, damit is_markdown greift):
local tmp = vim.fn.tempname() .. ".md"
vim.fn.writefile({
  "# Große Überschrift",
  "",
  "## Kleinere Überschrift",
  "",
  "Ein Absatz mit **fettem Text** und *kursiv* und `code`.",
  "",
  "> Ein Zitat.",
}, tmp)

-- fwp-Startpfad nachbilden:
require("foolscap.config").setup({ theme = "wp51", width = 65 })
vim.cmd("edit " .. tmp)
require("foolscap").room()

local buf = vim.api.nvim_get_current_buf()

check("prose aktiv", vim.b[buf].foolscap_prose == true)
check("markdown_visuals aktiv", vim.b[buf].foolscap_markdown_visuals == true)

local ns = vim.api.nvim_create_namespace("foolscap_markdown")
local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
local seen = {}
for _, m in ipairs(marks) do
  if m[4].hl_group then seen[m[4].hl_group] = true end
end

check("Extmarks vorhanden (>=6)", #marks >= 6)
check("H1-Extmark", seen["FoolscapMarkdownH1"] == true)
check("H2-Extmark", seen["FoolscapMarkdownH2"] == true)
check("Fett-Extmark", seen["FoolscapMarkdownBold"] == true)
check("Kursiv-Extmark", seen["FoolscapMarkdownItalic"] == true)
check("Code-Extmark", seen["FoolscapMarkdownCode"] == true)
check("Zitat-Extmark", seen["FoolscapMarkdownQuote"] == true)

-- H1 wird zentriert: ein inline-Virtualtext-Polster auf der ersten Zeile.
local h1_marks = vim.api.nvim_buf_get_extmarks(buf, ns, { 0, 0 }, { 0, -1 }, { details = true })
local has_pad = false
for _, m in ipairs(h1_marks) do
  if m[4].virt_text and m[4].virt_text_pos == "inline" then has_pad = true end
end
check("H1 zentriert (virt_text-Polster)", has_pad)

-- Sichtbarkeit: jede Pop-Gruppe muss Farbe ODER reverse tragen (nicht leer):
local function visible(name)
  local d = vim.api.nvim_get_hl(0, { name = name })
  return d.fg ~= nil or d.bg ~= nil or d.reverse == true
end
check("H1 sichtbar (Farbe/reverse)", visible("FoolscapMarkdownH1"))
check("Fett sichtbar (Farbe/reverse)", visible("FoolscapMarkdownBold"))

-- Text bleibt unverändert (** und # dürfen sichtbar bleiben):
local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
check("Text unverändert (# bleibt)", lines[1] == "# Große Überschrift")
check("Text unverändert (** bleibt)", lines[5]:find("**fettem Text**", 1, true) ~= nil)

os.remove(tmp)

if #fails == 0 then
  io.stderr:write("ALLE TESTS OK\n")
  vim.cmd("qa!")
else
  io.stderr:write(("%d TEST(S) FEHLGESCHLAGEN\n"):format(#fails))
  vim.cmd("cq")
end
