-- Prosa-Modus: weicher Umbruch, Rechtschreibung, Bewegung nach sichtbaren Zeilen.
local M = {}

local MOVE = { "j", "k", "0", "$" }

local function save_win_opts(win)
  if vim.w[win].foolscap_prose_win_opts then return end
  vim.w[win].foolscap_prose_win_opts = {
    wrap = vim.wo[win].wrap,
    linebreak = vim.wo[win].linebreak,
    breakindent = vim.wo[win].breakindent,
    list = vim.wo[win].list,
    spell = vim.wo[win].spell,
  }
end

local function restore_win_opts(win)
  local opts = vim.w[win].foolscap_prose_win_opts
  if not opts then return end
  for name, value in pairs(opts) do
    vim.wo[win][name] = value
  end
  vim.w[win].foolscap_prose_win_opts = nil
end

local function save_buf_opts(buf)
  if vim.b[buf].foolscap_prose_buf_opts then return end
  vim.b[buf].foolscap_prose_buf_opts = {
    textwidth = vim.bo[buf].textwidth,
    spelllang = vim.bo[buf].spelllang,
  }
end

local function restore_buf_opts(buf)
  local opts = vim.b[buf].foolscap_prose_buf_opts
  if not opts then return end
  for name, value in pairs(opts) do
    vim.bo[buf][name] = value
  end
  vim.b[buf].foolscap_prose_buf_opts = nil
end

function M.enable(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local cfg = require("foolscap.config").options
  local win = vim.api.nvim_get_current_win()
  save_win_opts(win)
  save_buf_opts(buf)
  vim.bo[buf].textwidth = 0
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
  vim.wo[win].list = false
  if cfg.spell then
    vim.wo[win].spell = true
    vim.bo[buf].spelllang = cfg.spelllang
  end
  if cfg.markdown_visuals then
    require("foolscap.markdown").enable(win, buf)
  end
  -- Bewegung folgt sichtbaren Zeilen, nicht Absätzen:
  if not vim.b[buf].foolscap_prose_maps then
    for _, k in ipairs({ "j", "k" }) do
      vim.keymap.set({ "n", "v" }, k, "g" .. k, { buffer = buf, silent = true })
    end
    vim.keymap.set("n", "0", "g0", { buffer = buf, silent = true })
    vim.keymap.set("n", "$", "g$", { buffer = buf, silent = true })
    -- Sanfte Typografie:
    if cfg.typography then
      vim.keymap.set("i", "--", "–", { buffer = buf })
      vim.keymap.set("i", "...", "…", { buffer = buf })
      vim.b[buf].foolscap_prose_typography_maps = true
    end
    vim.b[buf].foolscap_prose_maps = true
  end
  vim.b[buf].foolscap_prose = true
end

function M.disable(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  restore_win_opts(win)
  restore_buf_opts(buf)
  require("foolscap.markdown").disable(win, buf)
  if vim.b[buf].foolscap_prose_maps then
    for _, k in ipairs(MOVE) do pcall(vim.keymap.del, "n", k, { buffer = buf }) end
    for _, k in ipairs({ "j", "k" }) do pcall(vim.keymap.del, "v", k, { buffer = buf }) end
    if vim.b[buf].foolscap_prose_typography_maps then
      pcall(vim.keymap.del, "i", "--", { buffer = buf })
      pcall(vim.keymap.del, "i", "...", { buffer = buf })
    end
  end
  vim.b[buf].foolscap_prose_maps = false
  vim.b[buf].foolscap_prose_typography_maps = false
  vim.b[buf].foolscap_prose = false
end

function M.toggle(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.b[buf].foolscap_prose then M.disable(buf) else M.enable(buf) end
end

return M
