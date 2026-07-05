# Foolscap

> A writing tool for neovim — with the feel of a **typewriter** and **WordStar**.
> From the blank page to a finished **EPUB/PDF**. For people who write.

*("Foolscap" is an old paper size, named after its jester's-cap watermark: the
blank sheet waiting for you.)*

> ⚠️ **Early version (v0.1).** It works, but there are surely still bugs I
> haven't found. Feedback and bug reports are very welcome via the
> [Issues](../../issues).

> **🇩🇪 Auf Deutsch:** Dieses README ist **Englisch zuerst**, aber der
> vollständige **deutsche Text steht direkt darunter → [Deutsch](#deutsch). 👇**
> Foolscap selbst ist voll zweisprachig; die Grammatikprüfung bringt Deutsch
> gleich mit.

---

## Why Foolscap?

The building blocks already exist (Goyo, vim-pencil, ltex …). What was missing
was a **coherent whole**: a calm, distraction-free, Vim-based writing program
that

- **feels like a typewriter** — warm amber-phosphor light, a centered text
  column, and "typewriter scrolling" (the line you type stays mid-screen while
  the text rolls up like paper),
- watches your **grammar & style** live in several languages,
- counts **word goals**,
- builds your manuscript as **EPUB and PDF** with one keystroke,
- and can be used by someone who has **never touched Vim**.

You write in **Markdown** — simple, future-proof, readable everywhere.

## Features

| | |
|---|---|
| ✍️ **Prose mode** | soft wrap, motion by visible lines, spell-check, gentle typography (`--`→–, `...`→…) |
| 📝 **Markdown clarity** | headings, `**bold**`, `*italic*`, quotes and inline code are visually emphasized without changing the text |
| 🎞️ **Typewriter look** | monochrome amber/green/paper theme + typewriter scrolling |
| 🎯 **Focus** | centered text column (default 65 chars), dependency-free, any terminal |
| 📖 **Grammar & style** | multilingual via `ltex-ls` (English, German, …); spelling is left to the editor |
| 🔢 **Word goals** | daily goal + progress, also in the statusline |
| 📚 **Book export** | Markdown → EPUB + PDF (no forced TeX; PDF via headless Chrome) |
| 🔇 **No noise** | no sounds, no gimmicks — just you and the text |

## Requirements

- **neovim ≥ 0.10**
- *(optional, for grammar)* [`ltex-ls-plus`](https://github.com/ltex-plus/ltex-ls-plus)
  on your `PATH` — easiest is the release **with bundled Java** (no system Java needed)
- *(optional, for export)* `pandoc`; for PDF also `chromium`/`google-chrome`
  **or** a TeX engine

Run `:checkhealth foolscap` to see what's available.

## Install

**As a plugin** (with [lazy.nvim](https://github.com/folke/lazy.nvim)):

```lua
{
  "drdewes/foolscap.nvim",
  ft = { "markdown", "text", "asciidoc", "rst", "org" },
  opts = {
    languages = { "en-US", "de-DE" },  -- first = default; put your language first
    theme = "amber",                    -- amber | green | paper | none
    width = 65,
    keymaps = true,                     -- creates <leader>r…
  },
}
```

**As a standalone writing app** (for non-Vimmers) — runs as a separate neovim
app without touching your own config:

```sh
git clone https://github.com/drdewes/foolscap.nvim ~/.config/foolscap-nvim
echo "alias write='NVIM_APPNAME=foolscap-nvim nvim'" >> ~/.bashrc
```

Then start writing with `write mytext.md`. (Starter config lives in
[`bootstrap/`](bootstrap/).)

## Quick start

```vim
:Foolscap            " writing room on/off (prose + focus + typewriter + theme)
:FoolscapProgress    " word progress
:FoolscapGoal 1500   " daily goal
:FoolscapLanguage en-US   " switch grammar language
:FoolscapBuild       " build the book as EPUB/PDF
```

Markdown files open in prose mode automatically; get the full writing room with
`:Foolscap` (or `<leader>rr` if `keymaps = true`).

## Commands

| Command | Effect |
|---|---|
| `:Foolscap` | writing room on/off |
| `:FoolscapProse` | prose mode only |
| `:FoolscapFocus` | centered focus only |
| `:FoolscapProgress` | show word progress |
| `:FoolscapGoal {n}` | set daily goal |
| `:FoolscapGrammar` | grammar check on/off |
| `:FoolscapLanguage {lang}` | switch grammar language (e.g. `de-DE`) |
| `:FoolscapBuild` | build the book as EPUB/PDF |

## Default keymaps (`keymaps = true`)

`<leader>rr` writing room · `<leader>rp` prose · `<leader>rf` focus ·
`<leader>rg` progress · `<leader>rt` grammar · `<leader>rb` build

Also handy in the editor: `zg` add word to dictionary · `]g`/`[g` next/previous
grammar hint · `<leader>` + LSP code action to accept a correction.

## Configuration (defaults)

```lua
require("foolscap").setup({
  languages  = { "en-US", "de-DE" },   -- first = default
  spell      = true,
  spelllang  = "en,de",
  width      = 65,
  typewriter = true,
  theme      = "amber",        -- amber | green | paper | none
  goal       = 1000,
  markdown_visuals = true,
  typography = true,
  grammar    = true,
  keymaps    = false,
  build      = { formats = { "epub", "pdf" } },
})
```

## Thanks

Foolscap stands on many shoulders: the [LARBS](https://larbs.xyz) tradition
(Luke Smith), [Goyo](https://github.com/junegunn/goyo.vim),
[vim-pencil](https://github.com/preservim/vim-pencil) and
[ltex-ls(-plus)](https://github.com/ltex-plus/ltex-ls-plus). Built with
[Claude Code](https://claude.com/claude-code). Thank you.

## License

MIT — see [LICENSE](LICENSE).

---
---

## Deutsch

*Dieses README ist Englisch zuerst, weil Foolscap sich an ein weltweites
neovim-Publikum richtet. Der Autor (Holger, ein glücklicher Nicht-Programmierer)
hat es mit [Claude Code](https://claude.com/claude-code) für sich selbst gebaut
und unter MIT veröffentlicht, falls andere „Schreiberlinge" auch Freude daran
haben. Foolscap ist **voll zweisprachig** — alles funktioniert auf Deutsch
genauso, die Grammatikprüfung bringt Deutsch mit.*

> ⚠️ **Frühe Version (v0.1).** Es funktioniert, aber es steckt bestimmt noch der
> eine oder andere Fehler drin, den ich noch nicht gefunden habe. Rückmeldungen
> und Fehlerberichte sind sehr willkommen – gern über die [Issues](../../issues).

### Was ist Foolscap?

Ein Schreibwerkzeug für neovim – mit dem Gefühl von **Schreibmaschine** und
**WordStar**. Von der leeren Seite bis zum fertigen **EPUB/PDF**. Für Menschen,
die schreiben. *(„Foolscap" = ein altes englisches Papierformat, benannt nach dem
Narrenkappen-Wasserzeichen. Der leere Bogen, der auf dich wartet.)*

Die einzelnen Bausteine gibt es längst (Goyo, vim-pencil, ltex …). Was fehlte,
war ein **stimmiges Ganzes**: ein ruhiges, ablenkungsfreies Schreibprogramm auf
Vim-Basis, das

- sich **anfühlt wie eine Schreibmaschine** – warmes Bernstein-Phosphor-Licht,
  zentrierte Textspalte, und „Schreibmaschinen-Scrollen" (die Tippzeile bleibt in
  der Bildmitte, der Text wandert nach oben wie das Papier),
- dir **Grammatik & Stil** in mehreren Sprachen live über die Schulter schaut,
- **Wortziele** zählt,
- und auf einen Tastendruck dein Manuskript als **EPUB und PDF** baut,
- und das auch jemand benutzen kann, **der noch nie mit Vim gearbeitet hat.**

Du schreibst in **Markdown** – schlicht, zukunftssicher, überall lesbar.

### Funktionen

| | |
|---|---|
| ✍️ **Prosa-Modus** | weicher Umbruch, Bewegung nach sichtbaren Zeilen, Rechtschreibung, sanfte Typografie (`--`→–, `...`→…) |
| 📝 **Markdown-Klarheit** | Überschriften, `**fett**`, `*kursiv*`, Zitate und Inline-Code werden sichtbar hervorgehoben, ohne den Text zu verändern |
| 🎞️ **Schreibmaschinen-Look** | monochromes Bernstein-/Grün-/Papier-Thema + Schreibmaschinen-Scrollen |
| 🎯 **Fokus** | zentrierte Textspalte (Standard 65 Zeichen), dependency-frei, jedes Terminal |
| 📖 **Grammatik & Stil** | mehrsprachig über `ltex-ls` (Deutsch, Englisch, …); Rechtschreibung macht der Editor |
| 🔢 **Wortziele** | Tagesziel + Fortschritt, auch in der Statuszeile |
| 📚 **Buch-Export** | Markdown → EPUB + PDF (ohne TeX-Zwang, PDF via Chrome-Headless) |
| 🔇 **Kein Lärm** | keine Sounds, kein Schnickschnack – nur du und der Text |

### Voraussetzungen

- **neovim ≥ 0.10**
- *(optional, für Grammatik)* [`ltex-ls-plus`](https://github.com/ltex-plus/ltex-ls-plus)
  im PATH – am einfachsten der Release **mit gebündeltem Java** (kein System-Java nötig)
- *(optional, für Export)* `pandoc`; für PDF zusätzlich `chromium`/`google-chrome`
  **oder** eine TeX-Engine

`:checkhealth foolscap` sagt dir, was vorhanden ist.

### Installation

**Als Plugin** (mit [lazy.nvim](https://github.com/folke/lazy.nvim)):

```lua
{
  "drdewes/foolscap.nvim",
  ft = { "markdown", "text", "asciidoc", "rst", "org" },
  opts = {
    languages = { "de-DE", "en-US" },  -- erste = Standard
    theme = "amber",                    -- amber | green | paper | none
    width = 65,
    keymaps = true,                     -- legt <leader>r… an
  },
}
```

**Als eigenständiges Schreibprogramm** (für Nicht-Vimmer) – läuft als separate
neovim-App, ohne deine sonstige Konfiguration anzufassen:

```sh
git clone https://github.com/drdewes/foolscap.nvim ~/.config/foolscap-nvim
echo "alias schreiben='NVIM_APPNAME=foolscap-nvim nvim'" >> ~/.bashrc
```

Dann startest du dein Schreibprogramm einfach mit `schreiben meintext.md`.
(Die Starter-Konfiguration liegt in [`bootstrap/`](bootstrap/).)

### Schnellstart

```vim
:Foolscap            " Schreibraum an/aus (Prosa + Fokus + Schreibmaschine + Thema)
:FoolscapProgress    " Wort-Fortschritt
:FoolscapGoal 1500   " Tagesziel
:FoolscapBuild       " Buch als EPUB/PDF bauen
```

Markdown-Dateien öffnen automatisch im Prosa-Modus. Den vollen Schreibraum holst
du dir mit `:Foolscap` (oder `<leader>rr`, wenn `keymaps = true`).

### Befehle

| Befehl | Wirkung |
|---|---|
| `:Foolscap` | Schreibraum an/aus |
| `:FoolscapProse` | nur Prosa-Modus an/aus |
| `:FoolscapFocus` | nur zentrierten Fokus an/aus |
| `:FoolscapProgress` | Wort-Fortschritt zeigen |
| `:FoolscapGoal {n}` | Tagesziel setzen |
| `:FoolscapGrammar` | Grammatik-Check an/aus |
| `:FoolscapLanguage {lang}` | Grammatiksprache umschalten (z. B. `en-US`) |
| `:FoolscapBuild` | Buch als EPUB/PDF bauen |

### Standard-Tastenkürzel (`keymaps = true`)

`<leader>rr` Schreibraum · `<leader>rp` Prosa · `<leader>rf` Fokus ·
`<leader>rg` Fortschritt · `<leader>rt` Grammatik · `<leader>rb` Bauen

Im Editor zusätzlich nützlich: `zg` Wort ins Wörterbuch · `]g`/`[g` zum nächsten
Grammatik-Hinweis · `<leader>` + LSP-Code-Action zum Übernehmen einer Korrektur.

### Konfiguration (Vorgaben)

```lua
require("foolscap").setup({
  languages  = { "de-DE", "en-US" },
  spell      = true,
  spelllang  = "de,en",
  width      = 65,
  typewriter = true,
  theme      = "amber",        -- amber | green | paper | none
  goal       = 1000,
  typography = true,
  grammar    = true,
  keymaps    = false,
  build      = { formats = { "epub", "pdf" } },
})
```

### Dank

Foolscap steht auf den Schultern vieler: der [LARBS](https://larbs.xyz)-Tradition
(Luke Smith), [Goyo](https://github.com/junegunn/goyo.vim),
[vim-pencil](https://github.com/preservim/vim-pencil) und
[ltex-ls(-plus)](https://github.com/ltex-plus/ltex-ls-plus). Danke.

### Lizenz

MIT – siehe [LICENSE](LICENSE).
