# Contributing to apple-app-review-skills

Thank you for helping make App Store submission easier for everyone.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Submitting a Rejection Case](#submitting-a-rejection-case)
- [Adding or Improving a Skill](#adding-or-improving-a-skill)
- [Adding or Improving an Agent](#adding-or-improving-an-agent)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

---

## Skill Structure (agentskills.io spec)

This project follows the [agentskills.io specification](https://agentskills.io/specification). Each skill is a **directory** (not a flat file):

```
skills/{category}/{skill-name}/
├── SKILL.md          # Required — YAML frontmatter + instructions
├── references/       # Optional — guideline docs, sources
└── assets/           # Optional — templates, resources
```

**SKILL.md frontmatter requirements:**
- `name` — must match the parent directory name exactly (lowercase, hyphens only)
- `description` — one sentence describing what the skill checks and when to use it

Example:
```yaml
---
name: sdk-version-check
description: Detects apps built with outdated Xcode SDKs or deprecated iOS deployment targets that will be rejected under Guideline 2.5.10.
---
```

---

## How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/ugc-block-audit`
3. Make your changes (one skill or fix per branch)
4. Commit following the [Conventional Commits](#commit-message-convention) spec
5. Open a Pull Request with a clear description

---

## Submitting a Rejection Case

Real-world rejection cases are the foundation of this project. If your app was rejected:

1. Open an issue using the [Rejection Case template](.github/ISSUE_TEMPLATE/rejection_case.md)
2. Include:
   - The exact guideline number (e.g. `3.1.2(c)`)
   - The reviewer's rejection message (redact personal info)
   - The root cause you identified
   - The fix that worked

Accepted rejection cases are incorporated into the relevant skill file and credited in its **Real-World Cases** section.

---

## Adding or Improving a Skill

### Skill File Location

```
skills/<category>/<skill-name>.md
```

Categories: `layout`, `permissions`, `ugc`, `privacy`, `quality`, `business`, `metadata`

### Skill File Structure

Every skill must follow this structure:

```markdown
# Skill: <Name>

## Purpose
One sentence. What this skill does and which guideline it enforces.

## Apple Guideline
- Primary: X.X — <Guideline Title>
- Related: X.X, X.X

## Real-World Rejection Cases
<!-- At least one confirmed real case with source -->
- **Case:** <What happened>
  **Source:** <URL or "Apple Developer Forums", "Stack Overflow", etc.>
  **Root cause:** <Technical reason>
  **Fix:** <What resolved it>

## Trigger
When an agent or user should invoke this skill.

## Inputs
- Named inputs with descriptions

## Actions
Numbered, concrete, tool-explicit steps:
1. Use `Glob` to find ...
2. Use `Grep` to search for ...
3. Use `Read` to verify ...

## Output Format
- Structured findings list with 🔴/🟠/🟡/🟢 priority levels and actionable TODO items

## Tools Used
- Read, Grep, Glob, Edit, Bash, Write

## Constraints
- What this skill must NOT do
- Safety and scope limits

## Swift Anti-Pattern Reference
<!-- Link to examples/swift/ file -->
See `examples/swift/<Category>Patterns.swift`
```

### Requirements

- Must include at least one real-world rejection case with source
- Must reference the Apple Guideline number
- Must include a Swift anti-pattern reference
- Must be atomic: one skill = one responsibility

---

## Adding or Improving an Agent

### Agent File Location

```
agents/<agent-name>.md
```

### Agent File Structure

```markdown
# <Agent Name> Agent

## Purpose
One sentence describing the agent's goal.

## Skills Used
- `skills/<category>/<skill>.md` — what it provides

## Phase 1: Analysis (Read-Only)
What the agent reads/analyzes before making changes.
- Use `Read`, `Grep`, `Glob` only

## Phase 2: Audit
What the agent checks based on Phase 1 findings. **Read-only — no file edits.**

## Phase 3: Report
## Report Format
[Critical/High/Medium/Low] description — file:line

## Usage
/agent-name
```

---

## Commit Message Convention

This project follows **[Conventional Commits](https://www.conventionalcommits.org/)** — the same spec used by Angular, Vue, Next.js, and Turborepo.

### Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New skill, agent, or Swift example |
| `fix` | Correcting wrong guidance in existing skill/agent |
| `docs` | README, CONTRIBUTING, or documentation changes |
| `refactor` | Restructuring without behavior change |
| `chore` | File rename, move, dependency update |

### Scopes

`layout` · `permissions` · `ugc` · `privacy` · `quality` · `business` · `metadata` · `agents` · `docs` · `examples`

### Examples

```
feat(ugc): add ugc-safety-features skill with Guideline 1.2 cases
feat(business): add subscription-disclosure skill with 3.1.2(c) cases
fix(permissions): correct NSLocationAlways SDK propagation case
docs(readme): add PrivacyInfo.xcprivacy rejection case to table
chore(examples): add swift SubscriptionPatterns.swift
```

### Rules

- Use the **imperative mood** in the description ("add", not "added" or "adds")
- Keep the subject line under **72 characters**
- **One logical change per commit** — don't batch unrelated fixes
- Reference issue numbers in the footer: `Closes #42`

---

## Pull Request Process

1. **One PR = one skill or one fix** — do not batch unrelated changes
2. Fill out the [PR template](.github/PULL_REQUEST_TEMPLATE.md) completely
3. Ensure the skill you added/changed includes a real-world rejection case
4. If adding a new skill, also update `README.md` Skills Reference table
5. If adding an agent, update `README.md` Agents Reference table

PRs without a real-world rejection case reference or guideline citation will be asked to add one before merging.

---

## Questions?

Open a [Discussion](../../discussions) — we're happy to help scope new skill ideas.
