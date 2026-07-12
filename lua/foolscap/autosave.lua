-- Autospeichern: still sichern, damit beim Schreiben nichts verloren geht.
-- Greift nur bei echten, benannten, schreibbaren Dateien – niemals bei
-- Polster-/Scratch-Fenstern, Hilfe, Netrw usw.
local M = {}

local function speicherbar(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= "" then return false end          -- nur normale Dateipuffer
  if not vim.bo[buf].modifiable or vim.bo[buf].readonly then return false end
  if not vim.bo[buf].modified then return false end            -- nichts Ungespeichertes
  if vim.api.nvim_buf_get_name(buf) == "" then return false end -- unbenannt -> nicht speichern
  return true
end

-- Ein einzelner Puffer, still gesichert (update schreibt nur bei Änderungen).
function M.save(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not speicherbar(buf) then return end
  vim.api.nvim_buf_call(buf, function()
    pcall(vim.cmd, "silent lockmarks update")
  end)
end

function M.enable()
  local grp = vim.api.nvim_create_augroup("FoolscapAutosave", { clear = true })
  -- InsertLeave deckt den häufigsten Fall ab: sobald du den Einfügemodus
  -- verlässt (auch um ZZ/ZQ zu tippen), ist der Text bereits gesichert.
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
    group = grp,
    callback = function(a) M.save(a.buf) end,
    desc = "Foolscap: automatisch speichern",
  })
end

function M.disable()
  pcall(vim.api.nvim_del_augroup_by_name, "FoolscapAutosave")
end

return M
