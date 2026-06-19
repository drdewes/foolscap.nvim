-- Buch-Export: von Markdown zu EPUB/PDF. Bewusst ohne TeX-Zwang
-- (PDF über Chrome-Headless, falls vorhanden; sonst pandoc-PDF-Engine).
local M = {}

local function has(bin) return vim.fn.executable(bin) == 1 end

local function chrome()
  for _, c in ipairs({ "google-chrome-stable", "chromium", "chromium-browser", "google-chrome" }) do
    if has(c) then return c end
  end
  return nil
end

function M.run()
  local cfg = require("ribbon.config").options.build
  local src = vim.api.nvim_buf_get_name(0)
  if src == "" then
    vim.notify("Ribbon: Datei hat keinen Namen – erst speichern.", vim.log.levels.WARN)
    return
  end
  if not has("pandoc") then
    vim.notify("Ribbon: pandoc nicht gefunden (für den Export nötig).", vim.log.levels.ERROR)
    return
  end
  vim.cmd("silent! write")

  local dir = cfg.output_dir or (vim.fn.fnamemodify(src, ":h") .. "/.build")
  vim.fn.mkdir(dir, "p")
  local base = vim.fn.fnamemodify(src, ":t:r")
  local made = {}

  for _, fmt in ipairs(cfg.formats) do
    if fmt == "epub" then
      local out = dir .. "/" .. base .. ".epub"
      vim.fn.system({ "pandoc", src, "-o", out, "--toc", "--split-level=1" })
      if vim.v.shell_error == 0 then table.insert(made, out) end
    elseif fmt == "pdf" then
      local out = dir .. "/" .. base .. ".pdf"
      local ch = chrome()
      if ch then
        local html = dir .. "/" .. base .. ".html"
        vim.fn.system({ "pandoc", src, "-o", html, "--standalone", "--embed-resources" })
        vim.fn.system({ ch, "--headless", "--no-sandbox", "--disable-gpu",
          "--no-pdf-header-footer", "--print-to-pdf=" .. out, "file://" .. html })
      else
        vim.fn.system({ "pandoc", src, "-o", out }) -- benötigt eine TeX-Engine
      end
      if vim.fn.filereadable(out) == 1 then table.insert(made, out) end
    end
  end

  if #made > 0 then
    vim.notify("Ribbon: gebaut → " .. table.concat(made, "  "))
  else
    vim.notify("Ribbon: Export fehlgeschlagen (siehe :messages).", vim.log.levels.ERROR)
  end
end

return M
