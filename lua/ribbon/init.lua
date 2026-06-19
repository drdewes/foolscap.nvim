-- Ribbon – ein Schreibwerkzeug für neovim, mit dem Gefühl von Schreibmaschine & WordStar.
local M = {}
local config = require("ribbon.config")

-- Vollständiger Schreibraum: Prosa + zentrierte Spalte + Schreibmaschine + Thema.
function M.room()
  if vim.b.ribbon_room then
    M.room_off()
    return
  end
  local cfg = config.options
  require("ribbon.prose").enable()
  require("ribbon.focus").open(cfg.width)
  if cfg.typewriter then vim.wo.scrolloff = 999 end -- Schreibmaschinen-Scrollen
  if cfg.theme ~= "none" then require("ribbon.theme").apply(cfg.theme) end
  vim.b.ribbon_room = true
  vim.api.nvim_echo({ { "Ribbon: Schreibraum an" } }, false, {})
end

function M.room_off()
  require("ribbon.focus").close()
  vim.wo.scrolloff = 0
  require("ribbon.theme").restore()
  vim.b.ribbon_room = false
  vim.api.nvim_echo({ { "Ribbon: Schreibraum aus" } }, false, {})
end

function M.set_keymaps(prefix)
  prefix = prefix or "<leader>r"
  local map = vim.keymap.set
  map("n", prefix .. "r", M.room, { desc = "Ribbon: Schreibraum an/aus" })
  map("n", prefix .. "p", function() require("ribbon.prose").toggle() end, { desc = "Ribbon: Prosa-Modus" })
  map("n", prefix .. "f", function() require("ribbon.focus").toggle(config.options.width) end, { desc = "Ribbon: Fokus zentrieren" })
  map("n", prefix .. "g", function() require("ribbon.goals").echo() end, { desc = "Ribbon: Fortschritt" })
  map("n", prefix .. "t", function() require("ribbon.grammar").toggle() end, { desc = "Ribbon: Grammatik an/aus" })
  map("n", prefix .. "b", function() require("ribbon.build").run() end, { desc = "Ribbon: Buch bauen" })
end

function M.setup(opts)
  local cfg = config.setup(opts)
  require("ribbon.goals").set(cfg.goal)

  if cfg.grammar then
    local ok = require("ribbon.grammar").setup(cfg)
    if not ok and opts and opts.grammar == true then
      vim.schedule(function()
        vim.notify("Ribbon: ltex-ls(-plus) nicht gefunden – Grammatik aus. Siehe :checkhealth ribbon", vim.log.levels.WARN)
      end)
    end
  end

  if cfg.auto then
    local grp = vim.api.nvim_create_augroup("RibbonAuto", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = grp,
      pattern = cfg.filetypes,
      callback = function(a) require("ribbon.prose").enable(a.buf) end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = grp,
      pattern = "*",
      callback = function(a)
        if vim.b[a.buf].ribbon_prose then require("ribbon.goals").echo() end
      end,
    })
  end

  if cfg.keymaps then M.set_keymaps(cfg.keymap_prefix) end
end

return M
