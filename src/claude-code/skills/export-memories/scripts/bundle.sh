#!/usr/bin/env bash
# Bundle this project's Claude memory files into a tarball that can leave a container.
# Usage: bundle.sh [project-dir] [output-dir]
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
OUT_DIR="${2:-$PROJECT_DIR}"

# Claude derives the per-project memory path by replacing every non-alphanumeric
# character in the absolute project path with a hyphen.
SLUG=$(printf '%s' "$PROJECT_DIR" | sed 's/[^a-zA-Z0-9]/-/g')
MEM="$HOME/.claude/projects/$SLUG/memory"

if [ ! -d "$MEM" ]; then
  echo "No memory directory at: $MEM" >&2
  echo "Projects that do have one:" >&2
  find "$HOME/.claude/projects" -maxdepth 2 -name memory -type d 2>/dev/null >&2 || true
  exit 1
fi

shopt -s nullglob
files=("$MEM"/*.md)
if [ ${#files[@]} -eq 0 ]; then
  echo "Memory directory is empty: $MEM" >&2
  exit 1
fi

STAMP=$(date +%Y-%m-%d)
NAME="claude-memories-$STAMP"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/$NAME/memory"
cp "$MEM"/*.md "$STAGE/$NAME/memory/"

# Classify by the `type:` field in each file's frontmatter.
# feedback / user / reference describe how to work and travel to other projects.
# project describes this repo and does not.
MANIFEST="$STAGE/$NAME/MANIFEST.md"
{
  echo "# Memory export, $STAMP"
  echo
  echo "Source: \`$MEM\`"
  echo "Project: \`$PROJECT_DIR\`"
  echo
  echo "| File | Type | Portable |"
  echo "|---|---|---|"
} > "$MANIFEST"

for f in "$STAGE/$NAME"/memory/*.md; do
  base=$(basename "$f")
  if [ "$base" = "MEMORY.md" ]; then
    echo "| \`$base\` | index | rebuild by hand |" >> "$MANIFEST"
    continue
  fi
  type=$(grep -m1 -E '^[[:space:]]+type:[[:space:]]*' "$f" 2>/dev/null | sed 's/.*type:[[:space:]]*//' | tr -d '\r' || true)
  [ -z "$type" ] && type="unknown"
  case "$type" in
    feedback|user|reference) portable="yes" ;;
    project)                 portable="no" ;;
    *)                       portable="check" ;;
  esac
  echo "| \`$base\` | $type | $portable |" >> "$MANIFEST"
done

cat >> "$MANIFEST" <<'NOTES'

## Reusing these elsewhere

Drop the `.md` files into the other project's memory directory
(`~/.claude/projects/<sanitized-path>/memory/`), then add a one-line pointer for each to
that project's `MEMORY.md`. That index is loaded at session start; the files themselves are
read on demand. Never paste file contents into `MEMORY.md`.

A rule you expect to keep refining belongs in `~/.claude/CLAUDE.md` instead, which loads for
every project. Copies in separate memory directories diverge silently.

`originSessionId` in the frontmatter points at a session on the machine that wrote it.
Strip it on import.

**"Portable: yes" is a type check, not a content check.** A feedback file can still name a
specific repo, task file or test in its body, and needs rewording before it means anything
elsewhere. See the notes section below if one was added.
NOTES

mkdir -p "$OUT_DIR"
tar -czf "$OUT_DIR/$NAME.tar.gz" -C "$STAGE" "$NAME"

echo "Wrote: $OUT_DIR/$NAME.tar.gz"
echo "Files: ${#files[@]}"
echo "---- manifest ----"
cat "$MANIFEST"
