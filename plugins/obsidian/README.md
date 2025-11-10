# Obsidian Plugin for Claude Code

Personal plugin for managing brainstorming and planning documents in an Obsidian vault.

## Overview

This plugin provides the `vault-management` skill for Claude Code to create and manage structured documentation in your Obsidian vault using direct file system access. No MCP servers or Obsidian plugins required.

**Architecture:**
- **CLAUDE.md** - Minimal configuration (vault path, directory structure) loaded in every session
- **SKILL.md** - Detailed operations and conventions loaded on-demand when managing vault

## Features

- **Project Organization**: Structured project folders with consistent naming (`YYYY-MM-DD-name.md`)
- **Metadata-Driven**: Frontmatter (project, status, type, created) for filtering and discovery
- **Inbox Workflow**: Quick capture with promotion to full projects
- **Automatic Linking**: Wikilinks between related documents
- **Version Control Ready**: Git-friendly structure

## Installation & Configuration

1. Install this plugin via Claude Code plugin marketplace

2. Add to your `~/.claude/CLAUDE.md`:
   ```markdown
   # Obsidian Vault Integration
   @~/.claude/plugins/marketplaces/fnichol-plugins/plugins/obsidian/CLAUDE.md

   # Obsidian Vault Path Override (customize this)
   Primary vault: `~/Sync/Obsidian/fnichol`
   ```

   **Default vault path:** `~/Obsidian/vault` (if you don't add the override)

**What gets loaded:**
- **CLAUDE.md**: Vault location and basic structure (loads in every conversation - kept minimal for token efficiency)
- **vault-management skill**: Full operations, conventions, and validation rules (loads only when you use vault commands)

**Why this approach:**
- Plugin files stay generic and shareable
- Your personal vault path lives only in your `~/.claude/CLAUDE.md`
- Easy to customize without editing plugin files
- Works across plugin updates

## Usage

The `vault-management` skill activates automatically when you use trigger phrases:

**Creating & organizing:**
- "Save this as a new project"
- "Save to inbox" / "quick idea"
- "Create a [design/plan/brainstorm] doc for [project-name]"
- "Update [doc] in [project]"

**Managing projects:**
- "Promote that inbox note to a project"
- "List projects" / "show me all projects"
- "What's in [project]"
- "Mark [project] as active"

**Validation:**
- "Check [project] frontmatter"
- "Validate frontmatter"

## Directory Structure

```
<your-vault-path>/projects/
  _inbox/                    # Quick captures
  project-name/              # One folder per project
    YYYY-MM-DD-desc.md       # Timestamped documents
```

**File naming:** `YYYY-MM-DD-descriptive-name.md` (lowercase, hyphens)

**Note:** Replace `<your-vault-path>` with the path configured in your `~/.claude/CLAUDE.md`

## Document Metadata

Each document includes frontmatter:

```yaml
---
project: project-name        # Matches folder name or "inbox"
status: planning             # planning|active|paused|completed|archived
type: brainstorm            # brainstorm|design|plan|notes|retrospective
created: YYYY-MM-DD         # Creation date
updated: YYYY-MM-DD         # Optional: when revised
---
```

**Document types:**
- `brainstorm` - Initial idea exploration
- `design` - Architecture and approach
- `plan` - Implementation tasks
- `notes` - Working notes
- `retrospective` - Post-completion reflections

**Status values:**
- `planning` - Initial exploration
- `active` - Currently working
- `paused` - On hold
- `completed` - Finished
- `archived` - No longer relevant

## License

MIT
