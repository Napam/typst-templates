# Root task runner — operates across all templates
# Usage: just <recipe>    Run: just --list

templates := "templates/document templates/cv-pretty templates/cv-ats"

# Build example.pdf for every template (parallel)
build:
    #!/usr/bin/env bash
    set -euo pipefail
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    pids=()
    names=()
    for t in {{templates}}; do
        name=$(basename "$t")
        log="$tmpdir/$name.log"
        (
            just --justfile "$t/justfile" --working-directory "$t" build \
                >"$log" 2>&1
        ) &
        pids+=($!)
        names+=("$name")
    done
    rc=0
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            echo "✔ ${names[$i]}"
        else
            echo "✘ ${names[$i]} (failed)"
            rc=1
        fi
        # replay output prefixed with template name
        sed "s/^/  [${names[$i]}] /" "$tmpdir/${names[$i]}.log"
    done
    exit $rc

# Symlink .hooks/pre-commit into .git/hooks so it runs on every commit
setup-githook:
    mkdir -p .git/hooks
    ln -sf ../../.hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    @echo "✔ git pre-commit hook installed"

# Remove all generated PDFs across every template
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    for t in {{templates}}; do
        echo "▶ cleaning $t"
        just --justfile "$t/justfile" --working-directory "$t" clean
    done
