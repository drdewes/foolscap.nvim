-- Ribbon – Benutzerbefehle (laden ohne setup(), nutzen Vorgaben).
if vim.g.loaded_ribbon then return end
vim.g.loaded_ribbon = true

local function cmd(name, fn, opts)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end

cmd("Ribbon", function() require("ribbon").room() end, { desc = "Ribbon: Schreibraum an/aus" })
cmd("RibbonProse", function() require("ribbon.prose").toggle() end, { desc = "Prosa-Modus an/aus" })
cmd("RibbonFocus", function()
  require("ribbon.focus").toggle(require("ribbon.config").options.width)
end, { desc = "Zentrierten Fokus an/aus" })
cmd("RibbonProgress", function() require("ribbon.goals").echo() end, { desc = "Wort-Fortschritt zeigen" })
cmd("RibbonGoal", function(a)
  local n = require("ribbon.goals").set(a.args)
  vim.api.nvim_echo({ { "Ribbon: Tagesziel " .. n .. " Wörter" } }, false, {})
end, { nargs = 1, desc = "Tagesziel setzen" })
cmd("RibbonGrammar", function() require("ribbon.grammar").toggle() end, { desc = "Grammatik-Check an/aus" })
cmd("RibbonLanguage", function(a) require("ribbon.grammar").language(a.args) end,
  { nargs = 1, desc = "Grammatiksprache umschalten (z.B. en-US)" })
cmd("RibbonBuild", function() require("ribbon.build").run() end, { desc = "Buch bauen (EPUB/PDF)" })
