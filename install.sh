#!/usr/bin/env bash
# install.sh — apple-app-review-skills installer
# Copies all skills and agents to ~/.claude/

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}apple-app-review-skills installer${NC}"
echo "======================================="
echo ""

# Check Claude Code is installed
if [ ! -d "$CLAUDE_DIR" ]; then
  echo -e "${RED}Error:${NC} ~/.claude directory not found."
  echo "Please install Claude Code first: https://docs.anthropic.com/claude-code"
  exit 1
fi

# Create target directories
mkdir -p "$CLAUDE_DIR/skills/layout"
mkdir -p "$CLAUDE_DIR/skills/permissions"
mkdir -p "$CLAUDE_DIR/skills/ugc"
mkdir -p "$CLAUDE_DIR/skills/privacy"
mkdir -p "$CLAUDE_DIR/skills/quality"
mkdir -p "$CLAUDE_DIR/skills/business"
mkdir -p "$CLAUDE_DIR/skills/metadata"
mkdir -p "$CLAUDE_DIR/agents"

SKILLS_INSTALLED=0
AGENTS_INSTALLED=0
SKIPPED=0

install_file() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    echo -e "  ${YELLOW}skip${NC}  $(basename "$dst") (already exists — use --force to overwrite)"
    SKIPPED=$((SKIPPED + 1))
  else
    cp "$src" "$dst"
    echo -e "  ${GREEN}ok${NC}    $(basename "$dst")"
  fi
}

# --force flag: overwrite existing files
if [[ "$1" == "--force" ]]; then
  install_file() {
    local src="$1"
    local dst="$2"
    cp "$src" "$dst"
    echo -e "  ${GREEN}ok${NC}    $(basename "$dst")"
  }
fi

# Install skills
echo "Installing skills..."
for category in layout permissions ugc privacy quality business metadata; do
  src_dir="$REPO_DIR/skills/$category"
  dst_dir="$CLAUDE_DIR/skills/$category"
  if [ -d "$src_dir" ]; then
    for skill_file in "$src_dir"/*.md; do
      [ -f "$skill_file" ] || continue
      install_file "$skill_file" "$dst_dir/$(basename "$skill_file")"
      SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
    done
  fi
done

echo ""
echo "Installing agents..."
for agent_file in "$REPO_DIR/agents"/*.md; do
  [ -f "$agent_file" ] || continue
  install_file "$agent_file" "$CLAUDE_DIR/agents/$(basename "$agent_file")"
  AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
done

# Install commands
mkdir -p "$CLAUDE_DIR/commands"
for cmd_file in "$REPO_DIR/commands"/*.md; do
  [ -f "$cmd_file" ] || continue
  install_file "$cmd_file" "$CLAUDE_DIR/commands/$(basename "$cmd_file")"
done

echo ""
echo "======================================="
echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "  Skills installed: ${GREEN}$SKILLS_INSTALLED${NC}"
echo -e "  Agents installed: ${GREEN}$AGENTS_INSTALLED${NC}"
[ "$SKIPPED" -gt 0 ] && echo -e "  Skipped (existing): ${YELLOW}$SKIPPED${NC} — re-run with --force to overwrite"
echo ""
echo "Usage in Claude Code:"
echo "  /appstore-full-audit        — full pre-submission audit"
echo "  /ipad-layout-audit          — iPad layout check"
echo "  /permission-audit           — permissions check"
echo "  /ugc-safety-agent           — UGC report/block check"
echo "  /privacy-audit              — privacy compliance check"
echo ""
