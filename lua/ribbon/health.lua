-- :checkhealth ribbon
local M = {}

function M.check()
  local h = vim.health
  h.start("Ribbon")

  if vim.fn.has("nvim-0.10") == 1 then
    h.ok("neovim " .. tostring(vim.version()))
  else
    h.error("neovim ≥ 0.10 wird benötigt")
  end

  local ltex = nil
  for _, b in ipairs({ "ltex-ls-plus", "ltex-ls" }) do
    if vim.fn.executable(b) == 1 then ltex = b; break end
  end
  if ltex then
    h.ok("Grammatik: " .. ltex .. " gefunden")
  else
    h.warn("Grammatik: ltex-ls(-plus) nicht gefunden",
      { "Installiere ltex-ls-plus (Release mit gebündeltem Java) und lege es in den PATH." })
  end

  if vim.fn.executable("pandoc") == 1 then
    h.ok("Export: pandoc gefunden")
  else
    h.warn("Export: pandoc nicht gefunden (für EPUB/PDF nötig)")
  end

  local chrome = nil
  for _, c in ipairs({ "google-chrome-stable", "chromium", "chromium-browser", "google-chrome" }) do
    if vim.fn.executable(c) == 1 then chrome = c; break end
  end
  if chrome then
    h.ok("PDF: " .. chrome .. " (Chrome-Headless, kein TeX nötig)")
  else
    h.info("PDF: kein Chrome/Chromium – PDF dann über pandoc-TeX-Engine oder nur EPUB")
  end
end

return M
