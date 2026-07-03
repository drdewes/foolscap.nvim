-- Foolscap – Benutzerbefehle (laden ohne setup(), nutzen Vorgaben).
if vim.g.loaded_foolscap then return end
vim.g.loaded_foolscap = true

local function cmd(name, fn, opts)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end

cmd("Foolscap", function() require("foolscap").room() end, { desc = "Foolscap: Schreibraum an/aus" })
cmd("FoolscapProse", function() require("foolscap.prose").toggle() end, { desc = "Prosa-Modus an/aus" })
cmd("FoolscapFocus", function()
  require("foolscap.focus").toggle(require("foolscap.config").options.width)
end, { desc = "Zentrierten Fokus an/aus" })
cmd("FoolscapProgress", function() require("foolscap.goals").echo() end, { desc = "Wort-Fortschritt zeigen" })
cmd("FoolscapGoal", function(a)
  local n = require("foolscap.goals").set(a.args)
  vim.api.nvim_echo({ { "Foolscap: Tagesziel " .. n .. " Wörter" } }, false, {})
end, { nargs = 1, desc = "Tagesziel setzen" })
cmd("FoolscapGrammar", function() require("foolscap.grammar").toggle() end, { desc = "Grammatik-Check an/aus" })
cmd("FoolscapLanguage", function(a) require("foolscap.grammar").language(a.args) end,
  { nargs = 1, desc = "Grammatiksprache umschalten (z.B. en-US)" })
cmd("FoolscapBuild", function() require("foolscap.build").run() end, { desc = "Buch bauen (EPUB/PDF)" })
