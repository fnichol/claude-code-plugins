# Obsidian Vault Integration

## Vault Location
Primary vault: `~/Sync/Obsidian/fnichol`

## Project Documentation

**Directory Structure:**
- New projects: `~/Sync/Obsidian/fnichol/projects/<project-name>/`
- Quick captures: `~/Sync/Obsidian/fnichol/projects/_inbox/`

**File Naming:**
- Format: `YYYY-MM-DD-descriptive-name.md`
- Updates happen in place (preserve creation date)

**Required Frontmatter:**
```yaml
---
project: project-name
status: planning | active | paused | completed | archived
type: brainstorm | design | plan | notes | retrospective
created: YYYY-MM-DD
updated: YYYY-MM-DD  # when revised
---
```

**Linking:**
- Internal: Wikilinks `[[note-name]]`
- External: Markdown `[text](url)`
- Add Related Documents section
- Auto-link to existing vault notes

**Document Types:**
- `brainstorm` - Initial idea exploration
- `design` - Architecture and approach
- `plan` - Implementation tasks
- `notes` - Working notes
- `retrospective` - Post-completion reflections

**Status Values:**
- `planning` - Initial exploration
- `active` - Currently working
- `paused` - On hold
- `completed` - Finished
- `archived` - No longer relevant
