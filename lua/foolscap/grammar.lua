-- Grammatik & Stil über ltex-ls(-plus) und die eingebaute neovim-LSP.
-- Arbeitsteilung: Rechtschreibung macht der Editor (spell); ltex nur Grammatik/Stil.
local M = {}

local function find_cmd(cfg)
  if cfg.ltex_cmd then return cfg.ltex_cmd end
  for _, c in ipairs({ "ltex-ls-plus", "ltex-ls" }) do
    if vim.fn.executable(c) == 1 then return c end
  end
  return nil
end

local function morfologik_rule(lang)
  -- z.B. "de-DE" -> "MORFOLOGIK_RULE_DE_DE"
  return ("MORFOLOGIK_RULE_" .. lang:gsub("-", "_")):upper()
end

function M.setup(cfg)
  local cmd = find_cmd(cfg)
  if not cmd then return false end
  local langs = cfg.languages or { "de-DE" }
  local lang = langs[1]

  -- Persistenter Speicher (Wörterbuch / verborgene Fehlalarme / deaktivierte Regeln):
  local dir = vim.fn.stdpath("state") .. "/foolscap"
  local file = dir .. "/ltex.json"
  vim.fn.mkdir(dir, "p")
  local function load()
    local f = io.open(file, "r")
    local d = {}
    if f then
      local c = f:read("*a"); f:close()
      local ok, p = pcall(vim.json.decode, c)
      if ok and type(p) == "table" then d = p end
    end
    d.dictionary = d.dictionary or {}
    d.disabledRules = d.disabledRules or {}
    d.hiddenFalsePositives = d.hiddenFalsePositives or {}
    return d
  end
  local function save(d)
    local f = io.open(file, "w")
    if f then f:write(vim.json.encode(d)); f:close() end
  end
  local function add(dst, l, items)
    dst[l] = dst[l] or {}
    local seen = {}
    for _, v in ipairs(dst[l]) do seen[v] = true end
    for _, v in ipairs(items or {}) do
      if not seen[v] then table.insert(dst[l], v); seen[v] = true end
    end
  end

  local S = load()
  add(S.disabledRules, lang, { morfologik_rule(lang) }) -- Rechtschreibung macht der Editor

  vim.lsp.config("ltex", {
    cmd = { cmd },
    filetypes = cfg.filetypes,
    root_markers = { ".git", ".foolscap" },
    get_language_id = function(_, ft)
      if ft == "markdown" or ft == "vimwiki" or ft == "text" then return "markdown" end
      return ft
    end,
    settings = {
      ltex = {
        language = lang,
        dictionary = S.dictionary,
        disabledRules = S.disabledRules,
        hiddenFalsePositives = S.hiddenFalsePositives,
        additionalRules = { enablePickyRules = true },
        diagnosticSeverity = "information",
      },
    },
  })
  vim.lsp.enable("ltex")

  local function push()
    for _, c in ipairs(vim.lsp.get_clients({ name = "ltex" })) do
      c.settings = c.settings or {}
      c.settings.ltex = c.settings.ltex or {}
      c.settings.ltex.dictionary = S.dictionary
      c.settings.ltex.disabledRules = S.disabledRules
      c.settings.ltex.hiddenFalsePositives = S.hiddenFalsePositives
      c:notify("workspace/didChangeConfiguration", { settings = c.settings })
    end
  end

  -- Client-seitige Handler für die ltex-Code-Actions (persistent über Neustarts):
  vim.lsp.commands["_ltex.addToDictionary"] = function(c)
    for l, w in pairs((c.arguments[1] or {}).words or {}) do add(S.dictionary, l, w) end
    save(S); push()
  end
  vim.lsp.commands["_ltex.disableRules"] = function(c)
    for l, r in pairs((c.arguments[1] or {}).ruleIds or {}) do add(S.disabledRules, l, r) end
    save(S); push()
  end
  vim.lsp.commands["_ltex.hideFalsePositives"] = function(c)
    for l, fp in pairs((c.arguments[1] or {}).falsePositives or {}) do add(S.hiddenFalsePositives, l, fp) end
    save(S); push()
  end

  vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "‹" },
    underline = true,
    severity_sort = true,
    float = { border = "rounded", source = true },
  })
  M.languages = langs
  return true
end

-- Grammatiksprache zur Laufzeit umschalten (z.B. für ein englisches Kapitel):
function M.language(lang)
  for _, c in ipairs(vim.lsp.get_clients({ name = "ltex" })) do
    c.settings.ltex.language = lang
    c:notify("workspace/didChangeConfiguration", { settings = c.settings })
  end
  vim.api.nvim_echo({ { "Grammatiksprache: " .. lang } }, false, {})
end

function M.toggle()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.api.nvim_echo({ { "Grammatik-Check " .. (on and "aus" or "an") } }, false, {})
end

return M
