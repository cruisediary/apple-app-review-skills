#!/usr/bin/env bash
# uninstall.sh — apple-app-review-skills uninstaller
# Removes all skills, agents, and commands installed by install.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Parse flags ---
PROJECT_MODE=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --project) PROJECT_MODE=true ;;
    --dry-run) DRY_RUN=true ;;
  esac
done

# --- Resolve TARGET_DIR ---
if [ "$PROJECT_MODE" = true ]; then
  if ! git -C "$(pwd)" rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error:${NC} --project requires a git repository at the current directory."
    echo "cd to your iOS app repo root first, then re-run:"
    echo "  bash path/to/uninstall.sh --project"
    exit 1
  fi
  TARGET_DIR="$(pwd)/.claude"
  MODE_LABEL="project-level ($(pwd)/.claude/)"
else
  TARGET_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  MODE_LABEL="user-level ($TARGET_DIR/)"
fi

echo ""
echo -e "${BLUE}apple-app-review-skills uninstaller${NC}"
echo "======================================="
echo -e "  Mode: ${BLUE}${MODE_LABEL}${NC}"
[ "$DRY_RUN" = true ] && echo -e "  ${YELLOW}Dry run — no files will be deleted${NC}"
echo ""

if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${YELLOW}Nothing to do:${NC} $TARGET_DIR does not exist."
  exit 0
fi

REMOVED=0
NOT_FOUND=0

remove_path() {
  local path="$1"
  local label="$2"
  if [ -e "$path" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${BLUE}dry${NC}   $label"
    else
      rm -rf "$path"
      echo -e "  ${GREEN}rm${NC}    $label"
    fi
    REMOVED=$((REMOVED + 1))
  else
    echo -e "  ${YELLOW}skip${NC}  $label (not found)"
    NOT_FOUND=$((NOT_FOUND + 1))
  fi
}

# --- Remove skills ---
echo "Removing skills..."
for category in layout permissions ugc privacy quality business metadata; do
  src_dir="$REPO_DIR/skills/$category"
  dst_dir="$TARGET_DIR/skills/$category"
  if [ -d "$src_dir" ]; then
    for skill_dir in "$src_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name="$(basename "$skill_dir")"
      remove_path "$dst_dir/$skill_name" "skills/$category/$skill_name/"
    done
    # Remove the category dir if now empty
    if [ "$DRY_RUN" = false ] && [ -d "$dst_dir" ] && [ -z "$(ls -A "$dst_dir")" ]; then
      rmdir "$dst_dir"
    fi
  fi
done

echo ""
echo "Removing agents..."
for agent_file in "$REPO_DIR/agents"/*.md; do
  [ -f "$agent_file" ] || continue
  remove_path "$TARGET_DIR/agents/$(basename "$agent_file")" "agents/$(basename "$agent_file")"
done

echo ""
echo "Removing commands..."
for cmd_file in "$REPO_DIR/commands"/*.md; do
  [ -f "$cmd_file" ] || continue
  remove_path "$TARGET_DIR/commands/$(basename "$cmd_file")" "commands/$(basename "$cmd_file")"
done

echo ""
echo "======================================="
[ "$DRY_RUN" = true ] && echo -e "${YELLOW}Dry run complete — nothing was deleted.${NC}" || echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "  Mode:    ${BLUE}${MODE_LABEL}${NC}"
[ "$DRY_RUN" = false ] && echo -e "  Removed: ${GREEN}$REMOVED${NC}"
[ "$DRY_RUN" = true  ] && echo -e "  Would remove: ${BLUE}$REMOVED${NC}"
[ "$NOT_FOUND" -gt 0 ] && echo -e "  Not found:    ${YELLOW}$NOT_FOUND${NC}"
echo ""
