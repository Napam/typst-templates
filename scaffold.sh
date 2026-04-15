#!/usr/bin/env bash
set -euo pipefail

# ── Config ───────────────────────────────────────────────────
REPO="Napam/typst-templates"
BRANCH="main"

# ── Detect local vs remote mode ─────────────────────────────
# When run from a git clone, templates/ exists nearby. When piped via curl | bash, we download from GitHub.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd 2> /dev/null || echo "")"
if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/templates" ]]; then
    MODE="local"
else
    MODE="remote"
fi

# ── Usage ────────────────────────────────────────────────────
usage() {
    cat << 'USAGE'
Usage: scaffold.sh <target-dir> [template]

Scaffold a new Typst project from a template.

Arguments:
  target-dir   Directory to create (must not already exist)
  template     Template name (default: document)

What gets created:
  <target-dir>/
  ├── fonts/          Bundled fonts (self-contained, no repo dependency)
  ├── template.typ    The template file
  ├── main.typ        Your document (ready to edit)
  └── justfile        Build runner (pre-configured for local fonts)

Run locally (from a clone):
  ./scaffold.sh my-project
  ./scaffold.sh my-project document

Run via curl (no clone needed):
  curl -fsSL https://raw.githubusercontent.com/Napam/typst-templates/main/scaffold.sh | bash -s my-project
USAGE
    exit 1
}

# ── Shared helpers ───────────────────────────────────────────
list_templates() {
    local templates_dir="$1"
    find "$templates_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | paste -sd, -
}

copy_justfile() {
    local src_justfile="$1"
    local dest_justfile="$2"
    sed \
        -e 's|^src := "example.typ"|src := "main.typ"|' \
        "$src_justfile" > "$dest_justfile"
    if ! grep -q 'src := "main.typ"' "$dest_justfile"; then
        echo "Error: failed to rewrite src in justfile" >&2
        exit 1
    fi
}

do_scaffold() {
    local source_dir="$1"
    local repo_root="${2:-}"

    mkdir -p "$TARGET"

    if [[ -n "$repo_root" ]]; then
        # Remote mode: symlinks in the template point outside the tarball and
        # are broken. Instead, copy the actual font directories from the repo's
        # top-level fonts/ dir, using the symlink names to know which ones.
        mkdir -p "$TARGET/fonts"
        for link in "$source_dir/fonts/"*; do
            local name
            name="$(basename "$link")"
            cp -R "$repo_root/fonts/$name" "$TARGET/fonts/$name"
        done
    else
        # Local mode: dereference symlinks (-RL) so the scaffolded project
        # gets real font files and is fully self-contained.
        cp -RL "$source_dir/fonts" "$TARGET/fonts"
    fi

    cp "$source_dir/template.typ" "$TARGET/template.typ"
    cp "$source_dir/example.typ" "$TARGET/main.typ"
    copy_justfile "$source_dir/justfile" "$TARGET/justfile"

    # Copy any extra directories (e.g. icons/) that aren't fonts, example, template, or justfile.
    for entry in "$source_dir"/*; do
        local base
        base="$(basename "$entry")"
        case "$base" in
            fonts|template.typ|example.typ|justfile) continue ;;
        esac
        if [[ -d "$entry" ]]; then
            cp -R "$entry" "$TARGET/$base"
        fi
    done
}

# ── Args ─────────────────────────────────────────────────────
[[ $# -lt 1 ]] && usage

TARGET="$1"
TEMPLATE="${2:-document}"

# ── Validate ─────────────────────────────────────────────────
if [[ -e "$TARGET" ]]; then
    echo "Error: '$TARGET' already exists." >&2
    exit 1
fi

# ── Scaffold (local mode) ───────────────────────────────────
scaffold_local() {
    local templates_dir="$SCRIPT_DIR/templates"
    local template_dir="$templates_dir/$TEMPLATE"

    if [[ ! -d "$template_dir" ]]; then
        echo "Error: template '$TEMPLATE' not found." >&2
        echo "Available: $(list_templates "$templates_dir")" >&2
        exit 1
    fi

    do_scaffold "$template_dir"
}

# ── Scaffold (remote mode) ──────────────────────────────────
scaffold_remote() {
    # Check for required tools
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required for remote mode." >&2
        exit 1
    fi
    if ! command -v tar &> /dev/null; then
        echo "Error: tar is required for remote mode." >&2
        exit 1
    fi

    local tarball_url="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
    local repo_prefix
    repo_prefix="$(basename "$REPO")-$BRANCH"

    # Download repo tarball to a temp directory
    _tmpdir="$(mktemp -d)"
    trap 'rm -rf "$_tmpdir"' EXIT

    echo "Downloading from github.com/$REPO..."
    if ! curl -fsSL "$tarball_url" | tar xz -C "$_tmpdir"; then
        echo "Error: failed to download from $tarball_url" >&2
        exit 1
    fi

    local extracted="$_tmpdir/$repo_prefix"

    if [[ ! -d "$extracted/templates/$TEMPLATE" ]]; then
        echo "Error: template '$TEMPLATE' not found in repository." >&2
        if [[ -d "$extracted/templates" ]]; then
            echo "Available: $(list_templates "$extracted/templates")" >&2
        fi
        exit 1
    fi

    do_scaffold "$extracted/templates/$TEMPLATE" "$extracted"
}

# ── Run ──────────────────────────────────────────────────────
echo "Scaffolding '$TEMPLATE' template → $TARGET  (${MODE} mode)"

if [[ "$MODE" == "local" ]]; then
    scaffold_local
else
    scaffold_remote
fi

echo ""
echo "Done! Created:"
(cd "$TARGET" && find . -mindepth 1 -maxdepth 2 -not -path './.git/*' | sort | sed 's|^./||' | while read -r f; do
    if [[ -d "$f" ]]; then
        echo "  $f/"
    else
        echo "  $f"
    fi
done)
echo ""
echo "Next steps:"
echo "  cd \"$TARGET\""
echo "  just build          # or: just watch"
