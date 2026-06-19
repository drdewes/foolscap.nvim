# Ribbon

> Ein Schreibwerkzeug für neovim – mit dem Gefühl von **Schreibmaschine** und **WordStar**.
> Von der leeren Seite bis zum fertigen **EPUB/PDF**. Für Menschen, die schreiben.

*(„Ribbon" = das Farbband der Schreibmaschine. Arbeitstitel – der Name kann sich noch ändern.)*

---

## Warum Ribbon?

Die einzelnen Bausteine gibt es längst (Goyo, vim-pencil, ltex …). Was fehlte, war ein **stimmiges Ganzes**: ein ruhiges, ablenkungsfreies Schreibprogramm auf Vim-Basis, das

- sich **anfühlt wie eine Schreibmaschine** – warmes Bernstein-Phosphor-Licht, zentrierte Textspalte, und „Schreibmaschinen-Scrollen" (die Tippzeile bleibt in der Bildmitte, der Text wandert nach oben wie das Papier),
- dir **Grammatik & Stil** in mehreren Sprachen live über die Schulter schaut,
- **Wortziele** zählt,
- und auf einen Tastendruck dein Manuskript als **EPUB und PDF** baut,
- und das auch jemand benutzen kann, **der noch nie mit Vim gearbeitet hat.**

Du schreibst in **Markdown** – schlicht, zukunftssicher, überall lesbar.

## Funktionen

| | |
|---|---|
| ✍️ **Prosa-Modus** | weicher Umbruch, Bewegung nach sichtbaren Zeilen, Rechtschreibung, sanfte Typografie (`--`→–, `...`→…) |
| 🎞️ **Schreibmaschinen-Look** | monochromes Bernstein-/Grün-/Papier-Thema + Schreibmaschinen-Scrollen |
| 🎯 **Fokus** | zentrierte Textspalte (Standard 65 Zeichen), dependency-frei, jedes Terminal |
| 📖 **Grammatik & Stil** | mehrsprachig über `ltex-ls` (Deutsch, Englisch, …); Rechtschreibung macht der Editor |
| 🔢 **Wortziele** | Tagesziel + Fortschritt, auch in der Statuszeile |
| 📚 **Buch-Export** | Markdown → EPUB + PDF (ohne TeX-Zwang, PDF via Chrome-Headless) |
| 🔇 **Kein Lärm** | keine Sounds, kein Schnickschnack – nur du und der Text |

## Voraussetzungen

- **neovim ≥ 0.10**
- *(optional, für Grammatik)* [`ltex-ls-plus`](https://github.com/ltex-plus/ltex-ls-plus) im PATH – am einfachsten der Release **mit gebündeltem Java** (kein System-Java nötig)
- *(optional, für Export)* `pandoc`; für PDF zusätzlich `chromium`/`google-chrome` **oder** eine TeX-Engine

`:checkhealth ribbon` sagt dir, was vorhanden ist.

## Installation

### Als Plugin (für neovim-Nutzer)

Mit [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "DEIN-NAME/ribbon",
  ft = { "markdown", "text", "asciidoc", "rst", "org" },
  opts = {
    languages = { "de-DE", "en-US" },  -- erste = Standard
    theme = "amber",                    -- amber | green | paper | none
    width = 65,
    keymaps = true,                     -- legt <leader>r… an
  },
}
```

### Als eigenständiges Schreibprogramm (für Nicht-Vimmer)

Ribbon kann als **separate neovim-App** laufen, ganz ohne deine sonstige Konfiguration anzufassen:

```sh
git clone https://github.com/DEIN-NAME/ribbon ~/.config/ribbon-nvim
echo "alias schreiben='NVIM_APPNAME=ribbon-nvim nvim'" >> ~/.bashrc
```

Dann startest du dein Schreibprogramm einfach mit `schreiben meintext.md`.
(Die Starter-Konfiguration liegt in [`bootstrap/`](bootstrap/).)

## Schnellstart

```vim
:Ribbon            " Schreibraum an/aus (Prosa + Fokus + Schreibmaschine + Thema)
:RibbonProgress    " Wort-Fortschritt
:RibbonGoal 1500   " Tagesziel
:RibbonBuild       " Buch als EPUB/PDF bauen
```

Markdown-Dateien öffnen automatisch im Prosa-Modus. Den vollen Schreibraum holst
du dir mit `:Ribbon` (oder `<leader>rr`, wenn `keymaps = true`).

## Befehle

| Befehl | Wirkung |
|---|---|
| `:Ribbon` | Schreibraum an/aus |
| `:RibbonProse` | nur Prosa-Modus an/aus |
| `:RibbonFocus` | nur zentrierten Fokus an/aus |
| `:RibbonProgress` | Wort-Fortschritt zeigen |
| `:RibbonGoal {n}` | Tagesziel setzen |
| `:RibbonGrammar` | Grammatik-Check an/aus |
| `:RibbonLanguage {lang}` | Grammatiksprache umschalten (z. B. `en-US`) |
| `:RibbonBuild` | Buch als EPUB/PDF bauen |

## Standard-Tastenkürzel (`keymaps = true`)

`<leader>rr` Schreibraum · `<leader>rp` Prosa · `<leader>rf` Fokus ·
`<leader>rg` Fortschritt · `<leader>rt` Grammatik · `<leader>rb` Bauen

Im Editor zusätzlich nützlich: `zg` Wort ins Wörterbuch · `]g`/`[g` zum nächsten
Grammatik-Hinweis · `<leader>` + LSP-Code-Action zum Übernehmen einer Korrektur.

## Konfiguration (Vorgaben)

```lua
require("ribbon").setup({
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

## Dank

Ribbon steht auf den Schultern vieler: der [LARBS](https://larbs.xyz)-Tradition
(Luke Smith), [Goyo](https://github.com/junegunn/goyo.vim),
[vim-pencil](https://github.com/preservim/vim-pencil) und
[ltex-ls(-plus)](https://github.com/ltex-plus/ltex-ls-plus). Danke.

## Lizenz

MIT – siehe [LICENSE](LICENSE).
