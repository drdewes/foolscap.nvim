-- Ribbon – Starter-Konfiguration für die eigenständige Schreib-App.
--
-- Benutzung (ohne deine sonstige neovim-Config anzufassen):
--   git clone <repo> ~/.config/ribbon-nvim
--   alias schreiben='NVIM_APPNAME=ribbon-nvim nvim'
--   schreiben meintext.md
--
-- Holt Ribbon (und nur Ribbon) über lazy.nvim und richtet sinnvolle
-- Schreib-Vorgaben ein.

vim.g.mapleader = ","
vim.o.number = false
vim.o.ruler = false
vim.o.showmode = false
vim.o.laststatus = 2

-- lazy.nvim bei Bedarf selbst installieren:
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    -- Im Repo selbst: hier auf den lokalen Pfad zeigen lassen oder den
    -- GitHub-Namen eintragen, sobald veröffentlicht:
    dir = vim.fn.stdpath("config"),
    name = "ribbon",
    opts = {
      languages = { "de-DE", "en-US" },
      theme = "amber",
      width = 65,
      keymaps = true,
    },
    config = function(_, opts)
      require("ribbon").setup(opts)
    end,
  },
})

-- Direkt in den Schreibraum, sobald eine Textdatei geöffnet wird:
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text", "asciidoc", "rst", "org" },
      once = true,
      callback = function() vim.schedule(function() require("ribbon").room() end) end,
    })
  end,
})
