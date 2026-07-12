-- Fokus: zentrierte Schreibspalte über zwei leere "Polster"-Fenster links/rechts.
-- Dependency-frei (kein Goyo nötig), funktioniert in jedem Terminal.
local M = {}
local state = { active = false, pads = {}, main = nil, au = nil }

local function make_pad(win)
  local b = vim.api.nvim_create_buf(false, true)
  vim.bo[b].buftype = "nofile"
  vim.bo[b].bufhidden = "wipe"
  vim.bo[b].swapfile = false
  vim.api.nvim_win_set_buf(win, b)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = false
  vim.wo[win].winfixwidth = true
  vim.wo[win].list = false
  vim.wo[win].statusline = " "
  vim.wo[win].fillchars = "eob: "
  vim.wo[win].spell = false
end

function M.open(width)
  if state.active then return end
  width = width or 65
  local pad = math.floor((vim.o.columns - width) / 2)
  if pad < 2 then return end -- Fenster zu schmal: nichts tun
  local main = vim.api.nvim_get_current_win()

  vim.cmd("leftabove vsplit")
  local left = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(main)
  vim.cmd("rightbelow vsplit")
  local right = vim.api.nvim_get_current_win()

  make_pad(left)
  make_pad(right)
  vim.api.nvim_win_set_width(left, pad)
  vim.api.nvim_win_set_width(right, pad)

  vim.api.nvim_set_current_win(main)
  state = { active = true, pads = { left, right }, main = main, au = nil }

  -- Beim Beenden (ZZ/ZQ/:q) IM Textfenster zuerst die Rand-Polster schließen.
  -- Dann schließt das eigentliche Quit das (nun letzte) Textfenster und beendet
  -- neovim sauber – statt einen in einem leeren Polster-Fenster stranden zu lassen.
  state.au = vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      if state.active and vim.api.nvim_get_current_win() == state.main then
        M.close()
      end
    end,
    desc = "Foolscap: Polster beim Verlassen mitschließen",
  })
end

function M.close()
  if not state.active then return end
  if state.au then pcall(vim.api.nvim_del_autocmd, state.au) end
  for _, w in ipairs(state.pads) do
    if vim.api.nvim_win_is_valid(w) then pcall(vim.api.nvim_win_close, w, true) end
  end
  state = { active = false, pads = {}, main = nil, au = nil }
end

function M.toggle(width)
  if state.active then M.close() else M.open(width) end
end

function M.is_active() return state.active end

return M
