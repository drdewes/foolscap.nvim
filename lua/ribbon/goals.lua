-- Wortziele & Fortschritt.
local M = {}
local goal = 1000

function M.set(n)
  goal = tonumber(n) or goal
  return goal
end

function M.get() return goal end

function M.words()
  return vim.fn.wordcount().words
end

-- Für die Statuszeile: "742/1000"
function M.status()
  return string.format("%d/%d", M.words(), goal)
end

function M.echo()
  local w = M.words()
  local rest = goal - w
  local msg
  if rest > 0 then
    msg = string.format("%d / %d Wörter  (noch %d)", w, goal, rest)
  else
    msg = string.format("%d / %d Wörter  – Ziel erreicht! (+%d)", w, goal, -rest)
  end
  vim.api.nvim_echo({ { msg } }, false, {})
end

return M
