-- Ribbon – Konfiguration & Vorgaben.
local M = {}

M.defaults = {
  -- Sprachen für die Grammatikprüfung (erste = Standard):
  languages = { "de-DE", "en-US" },
  -- Rechtschreibung (neovim-eigen, NICHT ltex):
  spell = true,
  spelllang = "de,en",
  -- Breite der zentrierten Schreibspalte:
  width = 65,
  -- Schreibmaschinen-Scrollen (die Tippzeile bleibt vertikal mittig):
  typewriter = true,
  -- Optik im Schreibraum: "amber" | "green" | "paper" | "none"
  theme = "amber",
  -- Tages-Wortziel:
  goal = 1000,
  -- Dateitypen, für die der Prosa-Modus automatisch greift:
  filetypes = {
    "markdown", "markdown.pandoc", "vimwiki", "text", "tex", "asciidoc", "rst", "org",
  },
  auto = true, -- Prosa-Modus automatisch bei obigen Dateitypen
  -- Deutsche Typografie im Einfügemodus (-- -> –, ... -> …):
  typography = true,
  -- Grammatik aktivieren (ltex-ls / ltex-ls-plus muss installiert sein):
  grammar = true,
  ltex_cmd = nil, -- nil = automatisch suchen
  -- Optionale Standard-Tastenkürzel (Plugin-Nutzer setzen meist eigene):
  keymaps = false,
  keymap_prefix = "<leader>r",
  -- Buch-Export:
  build = {
    formats = { "epub", "pdf" },
    output_dir = nil, -- nil = <ordner-der-datei>/.build
  },
}

-- Schon vor setup() mit Vorgaben gefüllt, damit Befehle sofort funktionieren:
M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.options
end

return M
