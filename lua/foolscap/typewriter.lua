-- Schreibmaschinen-Scrollen: die Tippzeile bleibt vertikal in der Mitte –
-- auch beim Schreiben am Dokumentende (nicht nur in der Mitte wie bei scrolloff=999).
--
-- Trick: unter den Text werden virtuelle Leerzeilen gelegt, damit neovim auch die
-- letzte Zeile in die Bildschirmmitte scrollen kann. neovim kann von Haus aus nicht
-- über das Dateiende hinaus scrollen – die Extmark-Füllzeilen verändern die Datei
-- nicht, geben dem Fenster aber „Luft" zum Zentrieren.
local M = {}

local ns = vim.api.nvim_create_namespace("foolscap_typewriter")

-- Füllzeilen als virt_lines: eine Liste leerer Segmente.
local function fillers(n)
  local t = {}
  for i = 1, n do
    t[i] = { { "" } }
  end
  return t
end

-- Cursorzeile in die vertikale Mitte holen und den nötigen Freiraum unter dem
-- Text als virtuelle Zeilen bereitstellen. Zentriert ausschließlich über
-- winrestview (nur die Scrollposition) – NICHT über "normal! zz". zz würde im
-- Einfügemodus kurz in den Normalmodus springen und die Einfügeposition
-- verschieben, wodurch Zeichen verdreht wurden ("Holger" -> "olgerH").
local function do_center(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.b[buf].foolscap_tw then return end

  local height = vim.api.nvim_win_get_height(win)
  local half = math.floor(height / 2)
  local last = vim.api.nvim_buf_line_count(buf)

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  -- Freiraum unter der letzten Zeile: gibt dem Fenster „Luft", um auch die
  -- letzte Zeile in die Mitte zu holen (neovim scrollt sonst nicht über EOF).
  vim.api.nvim_buf_set_extmark(buf, ns, last - 1, 0, {
    virt_lines = fillers(half),
  })

  -- Nur scrollen: Cursor/Spalte/Modus bleiben unangetastet. Display-genau
  -- (zählt Zeilenumbrüche mit), indem topline schrittweise verschoben und die
  -- tatsächliche Bildschirmzeile des Cursors (winline) gemessen wird. Da ein
  -- langer Absatz EINE Pufferzeile ist (= mehrere Bildschirmzeilen), lässt sich
  -- die Mitte oft nicht exakt treffen – wir merken uns die beste topline und
  -- stellen am Ende die her, die den Cursor am nächsten zur Mitte bringt.
  vim.api.nvim_win_call(win, function()
    local lnum = vim.fn.winsaveview().lnum
    local function set_top(t)
      local v = vim.fn.winsaveview()
      v.topline = t
      v.skipcol = 0
      v.topfill = 0
      vim.fn.winrestview(v)
    end
    -- Cursorzeile ganz nach oben, dann Zeile für Zeile nach unten schieben,
    -- bis der Cursor die Bildschirmmitte erreicht; beste Trefferzeile merken.
    set_top(lnum)
    local best_top, best_err = lnum, math.abs(vim.fn.winline() - half)
    local top, guard = lnum, 0
    while top > 1 and guard < 200 do
      guard = guard + 1
      top = top - 1
      set_top(top)
      local err = math.abs(vim.fn.winline() - half)
      if err < best_err then best_err, best_top = err, top end
      if vim.fn.winline() >= half then break end
    end
    set_top(best_top)
  end)
end

-- Mehrfachauslösung (jede Taste) auf einen geplanten Lauf bündeln.
local pending = {}
local function recenter(win)
  win = win or vim.api.nvim_get_current_win()
  if pending[win] then return end
  pending[win] = true
  vim.schedule(function()
    pending[win] = nil
    do_center(win)
  end)
end

M.recenter = recenter

function M.enable(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.b[buf].foolscap_tw then return end

  vim.b[buf].foolscap_tw = true
  vim.b[buf].foolscap_tw_scrolloff = vim.wo[win].scrolloff
  vim.wo[win].scrolloff = 0 -- unser Zentrieren übernimmt, scrolloff würde stören

  local grp = vim.api.nvim_create_augroup("FoolscapTypewriter_" .. buf, { clear = true })
  vim.b[buf].foolscap_tw_grp = grp
  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "InsertLeave", "WinResized" },
    {
      group = grp,
      buffer = buf,
      callback = function()
        recenter(vim.api.nvim_get_current_win())
      end,
    }
  )
  -- Fenstergröße geändert (VimResized ist nicht buffer-lokal):
  vim.api.nvim_create_autocmd("VimResized", {
    group = grp,
    callback = function()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(w) and vim.b[vim.api.nvim_win_get_buf(w)].foolscap_tw then
          recenter(w)
        end
      end
    end,
  })

  recenter(win)
end

function M.disable(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.b[buf].foolscap_tw then return end

  local grp = vim.b[buf].foolscap_tw_grp
  if grp then pcall(vim.api.nvim_del_augroup_by_id, grp) end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if vim.api.nvim_win_is_valid(win) then
    vim.wo[win].scrolloff = vim.b[buf].foolscap_tw_scrolloff or 0
  end
  vim.b[buf].foolscap_tw = false
  vim.b[buf].foolscap_tw_grp = nil
end

return M
