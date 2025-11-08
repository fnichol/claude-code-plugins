# Plugin Marketplace Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a personal Claude Code plugin marketplace with monorepo structure and migrate the Obsidian plugin.

**Architecture:** Monorepo hosting plugins in `plugins/` subdirectory, with marketplace manifest at `.claude-plugin/marketplace.json`. Plugins maintain their complete structure and are referenced by relative paths.

**Tech Stack:** Git, GitHub, Claude Code Plugin System, JSON

---

## Task 1: Create Marketplace Structure

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `plugins/.gitkeep`

**Step 1: Create .claude-plugin directory**

```bash
mkdir -p .claude-plugin
```

**Step 2: Create marketplace.json**

Create `.claude-plugin/marketplace.json` with this content:

```json
{
  "name": "fnichol-plugins",
  "owner": {
    "name": "Fletcher Nichol",
    "email": "fnichol@nichol.ca"
  },
  "description": "Personal collection of Claude Code plugins",
  "pluginRoot": "./plugins",
  "plugins": []
}
```

**Step 3: Create plugins directory structure**

```bash
mkdir -p plugins
touch plugins/.gitkeep
```

**Step 4: Verify structure**

```bash
ls -la .claude-plugin/
ls -la plugins/
```

Expected: `.claude-plugin/marketplace.json` exists, `plugins/.gitkeep` exists

**Step 5: Commit marketplace structure**

```bash
git add .claude-plugin/marketplace.json plugins/.gitkeep
git commit -m "feat: add marketplace structure

Create marketplace manifest and plugins directory for Claude Code plugin
marketplace."
```

---

## Task 2: Create Marketplace README

**Files:**
- Create: `README.md`

**Step 1: Write README.md**

Create `README.md` with this content:

```markdown
# Fletcher's Claude Code Plugins

Personal collection of Claude Code plugins.

## Installation

Add this marketplace:

\`\`\`
/plugin marketplace add fnichol/claude-code-plugins
\`\`\`

Then browse and install plugins:

\`\`\`
/plugin install <plugin-name>@fnichol-plugins
\`\`\`

## Available Plugins

Currently empty. Plugins will be listed here as they are added.

## Development

Plugins are stored in `plugins/` with standard Claude Code plugin structure.
Each plugin maintains its complete directory layout:

\`\`\`
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    ├── agents/
    ├── skills/
    └── README.md
\`\`\`

To add a plugin:
1. Copy or create plugin in `plugins/new-plugin/`
2. Add entry to `.claude-plugin/marketplace.json`
3. Commit and push
```

**Step 2: Commit README**

```bash
git add README.md
git commit -m "docs: add marketplace README

Document installation and usage of the plugin marketplace."
```

---

## Task 3: Add MIT License

**Files:**
- Create: `LICENSE`

**Step 1: Create LICENSE file**

Create `LICENSE` with this content:

```
MIT License

Copyright (c) 2025 Fletcher Nichol

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Step 2: Commit license**

```bash
git add LICENSE
git commit -m "chore: add MIT license"
```

---

## Task 4: Migrate Obsidian Plugin

**Files:**
- Create: `plugins/obsidian/` (entire directory structure from `~/.claude/plugins/obsidian`)
- Modify: `.claude-plugin/marketplace.json`

**Step 1: Copy Obsidian plugin**

```bash
cp -r ~/.claude/plugins/obsidian plugins/
```

**Step 2: Verify plugin structure**

```bash
ls -la plugins/obsidian/.claude-plugin/plugin.json
cat plugins/obsidian/.claude-plugin/plugin.json
```

Expected: `plugin.json` exists and contains valid JSON with name, version, description

**Step 3: Check plugin version**

```bash
grep '"version"' plugins/obsidian/.claude-plugin/plugin.json
```

Note the version number (e.g., "0.1.0") for the next step.

**Step 4: Update marketplace.json to register Obsidian plugin**

Modify `.claude-plugin/marketplace.json` to add the Obsidian plugin to the plugins array:

```json
{
  "name": "fnichol-plugins",
  "owner": {
    "name": "Fletcher Nichol",
    "email": "fnichol@nichol.ca"
  },
  "description": "Personal collection of Claude Code plugins",
  "pluginRoot": "./plugins",
  "plugins": [
    {
      "name": "obsidian",
      "source": "./obsidian",
      "description": "Obsidian vault integration for Claude Code",
      "version": "0.1.0"
    }
  ]
}
```

Replace "0.1.0" with the actual version from `plugins/obsidian/.claude-plugin/plugin.json`.

**Step 5: Verify JSON is valid**

```bash
cat .claude-plugin/marketplace.json | python3 -m json.tool
```

Expected: Valid JSON output (no errors)

**Step 6: Commit Obsidian plugin**

```bash
git add plugins/obsidian/ .claude-plugin/marketplace.json
git commit -m "feat: add obsidian plugin

Migrate Obsidian vault integration plugin from local installation to
marketplace."
```

---

## Task 5: Update README with Obsidian Plugin

**Files:**
- Modify: `README.md`

**Step 1: Update Available Plugins section**

Replace the "Available Plugins" section in `README.md`:

```markdown
## Available Plugins

- **obsidian** - Obsidian vault integration for Claude Code
```

**Step 2: Commit README update**

```bash
git add README.md
git commit -m "docs: list obsidian plugin in README"
```

---

## Task 6: Push to GitHub

**Files:**
- N/A (Git operations only)

**Step 1: Verify we're on the initial-setup branch**

```bash
git branch --show-current
```

Expected: `initial-setup`

**Step 2: Check if remote exists**

```bash
git remote -v
```

**Step 3: Add remote if needed**

If no remote exists:

```bash
git remote add origin git@github.com:fnichol/claude-code-plugins.git
```

**Step 4: Push branch to GitHub**

```bash
git push -u origin initial-setup
```

Expected: Branch pushed successfully

**Step 5: Verify all commits pushed**

```bash
git log --oneline
```

Expected: All commits listed (marketplace structure, README, LICENSE, obsidian plugin, README update)

---

## Task 7: Test Marketplace Installation

**Files:**
- N/A (Testing only)

**Step 1: Document test command**

After pushing to GitHub, the marketplace can be tested with:

```bash
/plugin marketplace add fnichol/claude-code-plugins
```

**Step 2: Document plugin installation test**

After adding the marketplace, test installing the Obsidian plugin:

```bash
/plugin install obsidian@fnichol-plugins
```

**Step 3: Create testing notes**

Create a note documenting these test steps for verification after merging:

The implementation is complete. Manual testing steps:
1. Merge initial-setup branch to main
2. Run: `/plugin marketplace add fnichol/claude-code-plugins`
3. Verify marketplace appears in marketplace list
4. Run: `/plugin install obsidian@fnichol-plugins`
5. Verify Obsidian plugin installs and functions correctly

---

## Summary

This plan creates:
1. Marketplace structure with manifest and plugins directory
2. Documentation (README and LICENSE)
3. Migrated Obsidian plugin from local installation
4. Initial git commits ready to push to GitHub

After completion, the marketplace will be ready for use at `fnichol/claude-code-plugins`.
