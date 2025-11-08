# Obsidian Plugin for Claude Code

Personal plugin for managing brainstorming and planning documents in an Obsidian vault.

## Overview

This plugin provides a skill for Claude Code to create and manage structured documentation in your Obsidian vault using direct file system access. No MCP servers or Obsidian plugins required.

## Features

- **Project Organization**: Structured project folders with consistent naming
- **Metadata-Driven**: Frontmatter for filtering and discovery
- **Inbox Workflow**: Quick capture with promotion to full projects
- **Automatic Linking**: Wikilinks between related documents
- **Version Control Ready**: Git-friendly structure

## Configuration

The plugin reads configuration from `~/.claude/CLAUDE.md`. See the Obsidian Vault Integration section.

## Usage

Invoke the skill naturally through conversation:

- "Save this as a new project"
- "Save to inbox"
- "Add a design doc to <project-name>"
- "Promote that inbox note to a project"
- "List projects"

## Structure

```
~/Sync/Obsidian/fnichol/
  projects/
    _inbox/              # Quick captures
    <project-name>/      # One folder per project
```

## Document Types

- `brainstorm` - Initial idea exploration
- `design` - Architecture and approach
- `plan` - Implementation tasks
- `notes` - Working notes
- `retrospective` - Post-completion reflections

## Status Values

- `planning` - Initial exploration
- `active` - Currently working
- `paused` - On hold
- `completed` - Finished
- `archived` - No longer relevant

## License

MIT
