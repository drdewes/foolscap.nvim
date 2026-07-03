-- Prosa-Modus: weicher Umbruch, Rechtschreibung, Bewegung nach sichtbaren Zeilen.
local M = {}

local MOVE = { "j", "k", "0", "$" }

function M.enable(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local cfg = require("foolscap.config").options
  local win = vim.api.nvim_get_current_win()
  vim.bo[buf].textwidth = 0
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
  vim.wo[win].list = false
  if cfg.spell then
    vim.wo[win].spell = true
    vim.bo[buf].spelllang = cfg.spelllang
  end
  -- Bewegung folgt sichtbaren Zeilen, nicht Absätzen:
  for _, k in ipairs({ "j", "k" }) do
    vim.keymap.set({ "n", "v" }, k, "g" .. k, { buffer = buf, silent = true })
  end
  vim.keymap.set("n", "0", "g0", { buffer = buf, silent = true })
  vim.keymap.set("n", "$", "g$", { buffer = buf, silent = true })
  -- Sanfte Typografie:
  if cfg.typography then
    vim.keymap.set("i", "--", "–", { buffer = buf })
    vim.keymap.set("i", "...", "…", { buffer = buf })
  end
  vim.b[buf].foolscap_prose = true
end

function M.disable(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].wrap = false
  vim.wo[win].spell = false
  for _, k in ipairs(MOVE) do pcall(vim.keymap.del, "n", k, { buffer = buf }) end
  for _, k in ipairs({ "j", "k" }) do pcall(vim.keymap.del, "v", k, { buffer = buf }) end
  pcall(vim.keymap.del, "i", "--", { buffer = buf })
  pcall(vim.keymap.del, "i", "...", { buffer = buf })
  vim.b[buf].foolscap_prose = false
end

function M.toggle(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.b[buf].foolscap_prose then M.disable(buf) else M.enable(buf) end
end

return M
