# typst-templates

Template scaffolding system for typst documents, think shadcn, but for typst templates.

## Quick start

Scaffold a new project with one command (no clone needed):

```bash
# Create my-project using "document" template (default)
curl -fsSL https://raw.githubusercontent.com/Napam/typst-templates/main/scaffold.sh | bash -s my-project
```

```bash
# or specify template directly
curl -fsSL https://raw.githubusercontent.com/Napam/typst-templates/main/scaffold.sh | bash -s my-project document
```

Requires: [just](https://github.com/casey/just) (`brew install just` / `cargo install just`)

This creates a self-contained project with bundled fonts:

```
my-project/
├── fonts/          Atkinson Hyperlegible Next
├── template.typ    The template (yours to tweak)
├── main.typ        Your document (start writing here)
├── justfile        just build / just watch
└── typst.toml      Project root marker (for editor integration)
```

Then:

```bash
cd my-project
just build          # or: just watch
```

The available templates are:

| Name      | Description                                                                         |
| --------- | ----------------------------------------------------------------------------------- |
| document  | The default template. This template is for general documents                        |
| cv-ats    | ATS optimized CV template                                                           |
| cv-pretty | Template for pretty looking CV intended for people to read, but not as ATS friendly |

### From a local clone

```bash
git clone git@github.com:Napam/typst-templates.git
cd typst-templates
./scaffold.sh ~/Documents/my-report
./scaffold.sh ~/Documents/my-report document    # explicit template name
```

## Why not make them into packages?

1. Don't wanna deal with packages when I can just copy paste a single file and
   use and tweak as I want per document.
1. Just having a copy pasted template means zero dependencies and fully
   reproducible builds.

---

## Developer Guide

### Repo layout

```
typst-templates/
├── fonts/                          Shared font library (all available fonts)
│   ├── atkinson-hyperlegible-next/
│   │   ├── *.ttf
│   │   └── OFL.txt
│   └── ptsans/
│       ├── *.ttf
│       └── OFL.txt
├── templates/
│   └── document/                   One directory per template
│       ├── fonts/                  Symlinks → ../../fonts/<font-dir>
│       ├── template.typ            Template source
│       ├── example.typ             Example document that uses the template
│       └── justfile                Build runner (works in-repo and scaffolded)
├── scaffold.sh                     Project scaffolder (local + remote modes)
└── README.md
```

Each template's `fonts/` directory contains **symlinks** to the shared `fonts/`
at the repo root. This means the in-repo template directory mirrors the structure
of a scaffolded project — both use `export TYPST_FONT_PATHS := "fonts"` in the justfile.

### Adding a new template

1. Create `templates/<name>/` with these files:
   - **`template.typ`** — The template.
   - **`example.typ`** — A working example that imports and uses the template.
   - **`justfile`** — Copy from an existing template; adjust if needed.

2. Add any new fonts to `fonts/<font-dir>/` (include the `OFL.txt` license file).

3. Symlink the fonts your template needs:

   ```bash
   mkdir -p templates/<name>/fonts
   ln -s ../../../fonts/<font-dir> templates/<name>/fonts/<font-dir>
   ```

4. Add the new template to the root `justfile`'s `templates` list so that
   `just build` and `just clean` include it.

5. Test: `./scaffold.sh /tmp/test-project <name>` and run `just build` in the output.

### How fonts work

Fonts live in `fonts/` at the repo root. Each template symlinks only the fonts it
needs into its own `fonts/` directory. When scaffolding, `cp -RL` dereferences
these symlinks so the output project gets real copies — fully self-contained.

The symlink path is always `../../../fonts/<font-dir>` (three levels up from
`templates/<name>/fonts/`).

If a symlink is broken (target font directory doesn't exist), `just build` will
fail immediately in the template directory — you catch the problem at dev time.

### How `scaffold.sh` works

The scaffolder creates a self-contained project from a template. It runs in two
modes:

| Mode       | Trigger                                           | Font/template source               |
| ---------- | ------------------------------------------------- | ---------------------------------- |
| **Local**  | Run from a clone (`./scaffold.sh my-project`)     | Local `templates/` dir             |
| **Remote** | Piped via curl (`curl ... \| bash -s my-project`) | Downloads repo tarball from GitHub |

**What it does:**

1. Validates the target directory doesn't exist and the template name is valid.
2. Copies fonts via `cp -RL` (dereferences symlinks into real files).
3. Copies `template.typ` as-is and `example.typ` as `main.typ`.
4. Rewrites the justfile: `src` → `"main.typ"`.
5. Creates `typst.toml` — a project root marker for editor integration.

### Justfile conventions

Each template's justfile uses two settings:

```just
export TYPST_FONT_PATHS := "fonts"   # Bundled fonts dir (env var read by typst CLI)
src := "example.typ"                 # Default source file (scaffold changes to "main.typ")
```

The `TYPST_FONT_PATHS` environment variable is Typst's official mechanism for
additional font directories. The justfile exports it so that `typst compile` and
`typst watch` find the bundled fonts without system installation.

#### Editor integration (optional)

The env var covers `just build` and `just watch`, but your editor's language
server and preview tools run outside of `just` — they won't see
`TYPST_FONT_PATHS` unless you configure them separately.

<details>
<summary><strong>Neovim (tinymist + typst-preview.nvim)</strong></summary>

Scaffolded projects include a `typst.toml` at the project root. Tinymist uses
this file to detect the project root, so relative `fontPaths` resolve correctly
assuming tinymist is configured to recognize `typst.toml` as a root marker:

```lua
-- In your LSP config (e.g. lspconfig or vim.lsp.config):
vim.lsp.config("tinymist", {
    root_markers = { 'typst.toml', '.git' },
    settings = {
        fontPaths = { "fonts" },
    },
})
```

For typst-preview.nvim, which spawns a separate `tinymist preview` process, add
`--font-path` via `extra_args`. It walks upward to find `typst.toml` and uses
that directory as the root:

```lua
require('typst-preview').setup {
    extra_args = function(path_of_main_file)
        local main_dir = vim.fs.dirname(vim.fn.fnamemodify(path_of_main_file, ':p'))
        local found = vim.fs.find('typst.toml', { path = main_dir, upward = true })
        local root = #found > 0 and vim.fs.dirname(found[1]) or main_dir
        local font_dir = root .. '/fonts'
        if vim.uv.fs_stat(font_dir) then
            return { '--font-path', font_dir }
        end
        return {}
    end,
}
```

</details>

<details>
<summary><strong>VS Code (tinymist extension)</strong></summary>

Add to your workspace or user `settings.json`:

```json
{
  "tinymist.fontPaths": ["${workspaceFolder}/fonts"]
}
```

The VS Code extension handles both LSP and preview, so this single setting
covers both.

</details>

<details>
<summary><strong>Other editors / universal (direnv)</strong></summary>

If you use [direnv](https://direnv.net/), add a `.envrc` to each project:

```bash
export TYPST_FONT_PATHS="fonts"
```

Then `direnv allow`. This sets the env var for your entire shell session in that
directory, so every tool (CLI, LSP, preview) inherits it. The scaffolder does not
create this file by default — add it manually if you use direnv.

</details>
