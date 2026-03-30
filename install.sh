#!/usr/bin/env bash
# install.sh — apple-app-review-skills installer
# Copies all skills and agents to ~/.claude/ (user-level) or ./.claude/ (project-level)
# Skills follow the agentskills.io specification (https://agentskills.io/specification):
# each skill is a directory containing SKILL.md with YAML frontmatter.

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
FORCE_MODE=false

for arg in "$@"; do
  case "$arg" in
    --project) PROJECT_MODE=true ;;
    --force)   FORCE_MODE=true ;;
  esac
done

# --- Resolve TARGET_DIR ---
if [ "$PROJECT_MODE" = true ]; then
  if ! git -C "$(pwd)" rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error:${NC} --project requires a git repository at the current directory."
    echo "cd to your iOS app repo root first, then re-run:"
    echo "  bash path/to/install.sh --project"
    exit 1
  fi
  TARGET_DIR="$(pwd)/.claude"
  MODE_LABEL="project-level ($(pwd)/.claude/)"
else
  TARGET_DIR="$HOME/.claude"
  MODE_LABEL="user-level (~/.claude/)"
fi

echo ""
echo -e "${BLUE}apple-app-review-skills installer${NC}"
echo "======================================="
echo -e "  Mode: ${BLUE}${MODE_LABEL}${NC}"
echo ""

# --- Validate target ---
if [ "$PROJECT_MODE" = false ] && [ ! -d "$TARGET_DIR" ]; then
  echo -e "${RED}Error:${NC} ~/.claude directory not found."
  echo "Please install Claude Code first: https://docs.anthropic.com/claude-code"
  exit 1
fi

# --- Create target directories ---
mkdir -p "$TARGET_DIR/skills/layout"
mkdir -p "$TARGET_DIR/skills/permissions"
mkdir -p "$TARGET_DIR/skills/ugc"
mkdir -p "$TARGET_DIR/skills/privacy"
mkdir -p "$TARGET_DIR/skills/quality"
mkdir -p "$TARGET_DIR/skills/business"
mkdir -p "$TARGET_DIR/skills/metadata"
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/commands"

SKILLS_INSTALLED=0
AGENTS_INSTALLED=0
SKIPPED=0

install_file() {
  local src="$1"
  local dst="$2"
  if [ "$FORCE_MODE" = true ] || [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo -e "  ${GREEN}ok${NC}    $(basename "$dst")"
    return 0
  fi
  echo -e "  ${YELLOW}skip${NC}  $(basename "$dst") (already exists — use --force to overwrite)"
  SKIPPED=$((SKIPPED + 1))
  return 1
}

# --- Install skills ---
echo "Installing skills..."
for category in layout permissions ugc privacy quality business metadata; do
  src_dir="$REPO_DIR/skills/$category"
  dst_dir="$TARGET_DIR/skills/$category"
  if [ -d "$src_dir" ]; then
    for skill_dir in "$src_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name="$(basename "$skill_dir")"
      dst_skill="$dst_dir/$skill_name"
      if [ "$FORCE_MODE" = true ] || [ ! -d "$dst_skill" ]; then
        cp -r "$skill_dir" "$dst_dir/"
        echo -e "  ${GREEN}ok${NC}    $skill_name/"
        SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
      else
        echo -e "  ${YELLOW}skip${NC}  $skill_name/ (already exists — use --force to overwrite)"
        SKIPPED=$((SKIPPED + 1))
      fi
    done
  fi
done

echo ""
echo "Installing agents..."
for agent_file in "$REPO_DIR/agents"/*.md; do
  [ -f "$agent_file" ] || continue
  if install_file "$agent_file" "$TARGET_DIR/agents/$(basename "$agent_file")"; then
    AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
  fi
done

# --- Install commands ---
for cmd_file in "$REPO_DIR/commands"/*.md; do
  [ -f "$cmd_file" ] || continue
  install_file "$cmd_file" "$TARGET_DIR/commands/$(basename "$cmd_file")"
done

echo ""
echo "======================================="
echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "  Mode:             ${BLUE}${MODE_LABEL}${NC}"
echo -e "  Skills installed: ${GREEN}$SKILLS_INSTALLED${NC}"
echo -e "  Agents installed: ${GREEN}$AGENTS_INSTALLED${NC}"
[ "$SKIPPED" -gt 0 ] && echo -e "  Skipped (existing): ${YELLOW}$SKIPPED${NC} — re-run with --force to overwrite"
echo ""
if [ "$PROJECT_MODE" = true ]; then
  echo "To share with your team:"
  echo "  git add .claude/ && git commit -m 'chore: add app-review-skills'"
  echo ""
fi
echo "Usage in Claude Code:"
echo "  /appstore-full-audit        — full pre-submission audit"
echo "  /ipad-layout-audit          — iPad layout check"
echo "  /permission-audit           — permissions check"
echo "  /ugc-safety-agent           — UGC report/block check"
echo "  /privacy-audit              — privacy compliance check"
echo ""
