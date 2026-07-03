#!/usr/bin/env bash
set -euo pipefail

# Install playbook skills to Codex / Cursor / Claude Code via symlinks.
# Skills with platform overlays get a merged SKILL.md in platforms/.build/<target>/.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="$ROOT_DIR/platforms/.build"

target_name="codex"
force_replace=0

usage() {
  cat <<'EOF'
Usage: bash scripts/install-skills.sh [--target codex|cursor|claude] [--force]

Installs skills from this repository into the target tool's global skills directory.
Default target: codex

Options:
  --target <name>   codex, cursor, or claude
  --force           Replace existing non-symlink skill directories

Environment:
  AI_CODING_SKILLS_DIR   Override install destination
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      if [ "$#" -lt 2 ]; then
        echo "--target requires a value: codex, cursor, claude" >&2
        exit 1
      fi
      target_name="${2:-}"
      shift 2
      ;;
    --target=*)
      target_name="${1#--target=}"
      shift
      ;;
    --force)
      force_replace=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$target_name" in
  codex)
    default_target="$HOME/.codex/skills"
    ;;
  cursor)
    default_target="$HOME/.cursor/skills"
    ;;
  claude)
    default_target="$HOME/.claude/skills"
    ;;
  *)
    echo "unknown target: $target_name" >&2
    echo "supported targets: codex, cursor, claude" >&2
    exit 1
    ;;
esac

TARGET_DIR="${AI_CODING_SKILLS_DIR:-$default_target}"
OVERLAY_DIR="$ROOT_DIR/platforms/$target_name/overlays"
BUILD_DIR="$BUILD_ROOT/$target_name"
MANIFEST="$ROOT_DIR/platforms/$target_name/manifest.yaml"

mkdir -p "$TARGET_DIR" "$BUILD_DIR"

skill_has_overlay() {
  local name="$1"
  [ -f "$OVERLAY_DIR/${name}.md" ]
}

extract_skill_body() {
  local file="$1"
  awk '
    BEGIN { in_frontmatter = 0; frontmatter_count = 0 }
    /^---$/ {
      frontmatter_count++
      if (frontmatter_count == 1) {
        in_frontmatter = 1
        next
      }
      if (frontmatter_count == 2) {
        in_frontmatter = 0
        next
      }
    }
    in_frontmatter == 0 && frontmatter_count >= 2 { print }
  ' "$file"
}

build_overlay_skill() {
  local name="$1"
  local source_dir="$ROOT_DIR/skills/$name"
  local out_dir="$BUILD_DIR/$name"
  local overlay_file="$OVERLAY_DIR/${name}.md"
  local source_skill="$source_dir/SKILL.md"

  if [ ! -f "$source_skill" ]; then
    echo "missing source skill: $source_skill" >&2
    return 1
  fi

  mkdir -p "$out_dir"
  cat "$overlay_file" > "$out_dir/SKILL.md"
  extract_skill_body "$source_skill" >> "$out_dir/SKILL.md"

  if [ -d "$source_dir/references" ]; then
    rm -rf "$out_dir/references"
    cp -R "$source_dir/references" "$out_dir/references"
  fi

  printf '%s\n' "$out_dir"
}

install_skill_link() {
  local name="$1"
  local link_target="$2"
  local target="$TARGET_DIR/$name"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    if [ "$force_replace" -eq 1 ]; then
      rm -rf "$target"
    else
      echo "skip existing non-symlink (use --force): $target" >&2
      return 2
    fi
  fi

  ln -s "$link_target" "$target"
  echo "linked $name -> $target -> $link_target"
  return 0
}

linked_count=0
skipped_count=0

for skill_dir in "$ROOT_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  [ -f "$skill_dir/SKILL.md" ] || continue

  if skill_has_overlay "$name"; then
    built_dir="$(build_overlay_skill "$name")"
    install_skill_link "$name" "$built_dir"
    rc=$?
  else
    install_skill_link "$name" "$skill_dir"
    rc=$?
  fi

  case "$rc" in
    0) linked_count=$((linked_count + 1)) ;;
    2) skipped_count=$((skipped_count + 1)) ;;
    *) exit "$rc" ;;
  esac
done

echo "done. target=$target_name dir=$TARGET_DIR linked=$linked_count skipped=$skipped_count"
if [ -f "$MANIFEST" ]; then
  echo "manifest: $MANIFEST"
fi
