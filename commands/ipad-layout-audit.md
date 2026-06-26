Determine the Claude config directory:
- If the `CLAUDE_CONFIG_DIR` environment variable is set, use that path
- Otherwise use `~/.claude`

Then read the file `agents/ipad-layout-agent.md` inside that directory and execute all instructions in it against the current project.
