-- Buch-Export: von Markdown zu EPUB/PDF. Bewusst ohne TeX-Zwang
-- (PDF über Chrome-Headless, falls vorhanden; sonst pandoc-PDF-Engine).
local M = {}

local function has(bin) return vim.fn.executable(bin) == 1 end
local function short(msg)
  msg = vim.trim(msg or "")
  if msg == "" then return "" end
  local lines = vim.split(msg, "\n", { plain = true, trimempty = true })
  local kept = {}
  for i = 1, math.min(#lines, 6) do
    kept[i] = lines[i]
  end
  return table.concat(kept, "\n")
end

local function run(args)
  local output = vim.fn.system(args)
  return vim.v.shell_error == 0, output
end

local function chrome()
  for _, c in ipairs({ "google-chrome-stable", "chromium", "chromium-browser", "google-chrome" }) do
    if has(c) then return c end
  end
  return nil
end

function M.run()
  local cfg = require("foolscap.config").options.build
  local src = vim.api.nvim_buf_get_name(0)
  if src == "" then
    vim.notify("Foolscap: Datei hat keinen Namen – erst speichern.", vim.log.levels.WARN)
    return
  end
  if not has("pandoc") then
    vim.notify("Foolscap: pandoc nicht gefunden (für den Export nötig).", vim.log.levels.ERROR)
    return
  end
  vim.cmd("silent! write")

  local dir = cfg.output_dir or (vim.fn.fnamemodify(src, ":h") .. "/.build")
  vim.fn.mkdir(dir, "p")
  local base = vim.fn.fnamemodify(src, ":t:r")
  local made = {}
  local errors = {}

  for _, fmt in ipairs(cfg.formats) do
    if fmt == "epub" then
      local out = dir .. "/" .. base .. ".epub"
      local ok, output = run({ "pandoc", src, "-o", out, "--toc", "--split-level=1" })
      if ok then
        table.insert(made, out)
      else
        table.insert(errors, "EPUB: " .. short(output))
      end
    elseif fmt == "pdf" then
      local out = dir .. "/" .. base .. ".pdf"
      local ch = chrome()
      if ch then
        local html = dir .. "/" .. base .. ".html"
        local ok, output = run({ "pandoc", src, "-o", html, "--standalone", "--embed-resources" })
        if ok then
          ok, output = run({ ch, "--headless", "--no-sandbox", "--disable-gpu",
            "--no-pdf-header-footer", "--print-to-pdf=" .. out, "file://" .. html })
        end
        if not ok then table.insert(errors, "PDF: " .. short(output)) end
      else
        local ok, output = run({ "pandoc", src, "-o", out }) -- benötigt eine TeX-Engine
        if not ok then table.insert(errors, "PDF: " .. short(output)) end
      end
      if vim.fn.filereadable(out) == 1 then table.insert(made, out) end
    end
  end

  if #made > 0 then
    local details = #errors > 0 and ("\nNicht gebaut:\n" .. table.concat(errors, "\n")) or ""
    local level = #errors > 0 and vim.log.levels.WARN or vim.log.levels.INFO
    vim.notify("Foolscap: gebaut → " .. table.concat(made, "  ") .. details, level)
  else
    local details = #errors > 0 and ("\n" .. table.concat(errors, "\n")) or ""
    vim.notify("Foolscap: Export fehlgeschlagen." .. details, vim.log.levels.ERROR)
  end
end

return M
