-- Foolscap – ein Schreibwerkzeug für neovim, mit dem Gefühl von Schreibmaschine & WordStar.
local M = {}
local config = require("foolscap.config")

-- Vollständiger Schreibraum: Prosa + zentrierte Spalte + Schreibmaschine + Thema.
function M.room()
  if vim.b.foolscap_room then
    M.room_off()
    return
  end
  local cfg = config.options
  vim.b.foolscap_room_had_prose = vim.b.foolscap_prose == true
  require("foolscap.prose").enable()
  require("foolscap.focus").open(cfg.width)
  if cfg.typewriter then require("foolscap.typewriter").enable() end -- Schreibmaschinen-Scrollen
  if cfg.theme ~= "none" then require("foolscap.theme").apply(cfg.theme) end
  vim.b.foolscap_room = true
  vim.api.nvim_echo({ { "Foolscap: Schreibraum an" } }, false, {})
end

function M.room_off()
  require("foolscap.focus").close()
  require("foolscap.typewriter").disable()
  require("foolscap.theme").restore()
  if not vim.b.foolscap_room_had_prose then
    require("foolscap.prose").disable()
  end
  vim.b.foolscap_room_had_prose = nil
  vim.b.foolscap_room = false
  vim.api.nvim_echo({ { "Foolscap: Schreibraum aus" } }, false, {})
end

function M.set_keymaps(prefix)
  prefix = prefix or "<leader>r"
  local map = vim.keymap.set
  map("n", prefix .. "r", M.room, { desc = "Foolscap: Schreibraum an/aus" })
  map("n", prefix .. "p", function() require("foolscap.prose").toggle() end, { desc = "Foolscap: Prosa-Modus" })
  map("n", prefix .. "f", function() require("foolscap.focus").toggle(config.options.width) end, { desc = "Foolscap: Fokus zentrieren" })
  map("n", prefix .. "g", function() require("foolscap.goals").echo() end, { desc = "Foolscap: Fortschritt" })
  map("n", prefix .. "t", function() require("foolscap.grammar").toggle() end, { desc = "Foolscap: Grammatik an/aus" })
  map("n", prefix .. "b", function() require("foolscap.build").run() end, { desc = "Foolscap: Buch bauen" })
end

function M.setup(opts)
  local cfg = config.setup(opts)
  require("foolscap.goals").set(cfg.goal)

  if cfg.grammar then
    local ok = require("foolscap.grammar").setup(cfg)
    if not ok and opts and opts.grammar == true then
      vim.schedule(function()
        vim.notify("Foolscap: ltex-ls(-plus) nicht gefunden – Grammatik aus. Siehe :checkhealth foolscap", vim.log.levels.WARN)
      end)
    end
  end

  if cfg.auto then
    local grp = vim.api.nvim_create_augroup("FoolscapAuto", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = grp,
      pattern = cfg.filetypes,
      callback = function(a) require("foolscap.prose").enable(a.buf) end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = grp,
      pattern = "*",
      callback = function(a)
        if vim.b[a.buf].foolscap_prose then require("foolscap.goals").echo() end
      end,
    })
  end

  if cfg.autosave then require("foolscap.autosave").enable() end

  if cfg.keymaps then M.set_keymaps(cfg.keymap_prefix) end
end

return M
