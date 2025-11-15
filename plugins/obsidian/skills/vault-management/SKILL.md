---
name: vault-management
description: Use when user says "save this", "create project", "promote from inbox", or organizing Obsidian documentation - manages frontmatter (project/status/type/created), file naming (YYYY-MM-DD-name.md), wikilinks, and project structure in user's Obsidian vault
---

# Obsidian Vault Management

## Overview

Direct file system management for Obsidian project documentation. Enforces YYYY-MM-DD-name.md naming, generates frontmatter, maintains wikilinks, organizes into projects/<name>/ and _inbox/.

## Configuration

**Vault path:** Look for "Primary vault:" in conversation context (from CLAUDE.md).
- Use the most recent occurrence if multiple are present (user override takes precedence)
- Default: `~/Obsidian/vault` if not specified
- Expand `~` to user's home directory before using

## Project Linking Configuration

**CLAUDE.local.md detection:** Check for `CLAUDE.local.md` in working directory at session start.

**Parse configuration fields:**
- `Vault project: \`project-name\`` - Links working directory to vault project
- `Local docs: ./path` - Optional local documentation directory
- `Documentation style: standard` - Optional style override

**Configuration precedence:**
- CLAUDE.local.md overrides for project-specific settings
- ~/.claude/CLAUDE.md for vault path (Primary vault:)
- Defaults: vault path `~/Obsidian/vault`, no local docs

**Example CLAUDE.local.md:**
```markdown
# Obsidian Project
Vault project: `my-project-name`
Local docs: `./docs`
Documentation style: standard
```

**Session context:**
Store parsed values in memory for the session:
- `project_name` - from Vault project field
- `local_docs_path` - from Local docs field (optional)
- `doc_style` - from Documentation style field (optional, default: adapt)

## Startup Behavior

**When CLAUDE.local.md contains `Vault project:` reference:**

### 1. Silent Index Loading

**Trigger:** Session starts in directory with CLAUDE.local.md containing Vault project field

**Process:**
1. Parse CLAUDE.local.md for `Vault project: \`name\``
2. Determine vault path from "Primary vault:" in context (see Configuration)
3. Expand `~` to home directory in vault path
4. Construct project path: `<vault-path>/projects/<project-name>/`
5. Read all `.md` files in project folder
6. Extract from each file's frontmatter:
   - filename (for reference)
   - `type:` field (brainstorm, design, plan, notes, retrospective)
   - `status:` field (planning, active, paused, completed, archived)
7. Store index in memory as session context

**Silent Success:**
- No output to user
- Index available for search/list operations

**Visible Warnings:**
- Vault path doesn't exist: "Warning: Vault path `<path>` not found. Check Primary vault in ~/.claude/CLAUDE.md"
- Project doesn't exist: "Note: Vault project `<name>` not found - will create on first save"
- Permission error: "Error: Cannot read vault project `<name>` at `<path>` - permission denied"

### 2. Local Docs Verification

**If `Local docs:` configured:**
1. Verify directory exists relative to working directory
2. If not found: "Warning: Local docs directory `<path>` not found. Create it or update CLAUDE.local.md"
3. Do not auto-create (respect project structure)

**Session Ready:**
After startup, Claude knows:
- All vault documents (from index)
- Local docs location (if configured)
- Ready for document operations

## When to Use

**User triggers:**
- "Save this" / "create project" / "save to inbox"
- "Create a [design/plan/brainstorm] doc for [project]"
- "Promote that note to a project"
- "Update [doc] in [project]"
- "List projects" / "show me what's in [project]"

**Use this skill for:** Project documentation, design docs, brainstorms, plans, retrospectives
**Don't use for:** Code documentation (use project CLAUDE.md), one-off notes outside vault

## Quick Reference

| Operation | Command Pattern | Result |
|-----------|----------------|--------|
| New project | "save as new project" | `projects/<name>/YYYY-MM-DD-<type>.md` |
| Save inbox | "save to inbox" | `projects/_inbox/YYYY-MM-DD-<desc>.md` |
| Add to project | "create [type] doc for [project]" | New doc + wikilinks to related |
| Update doc | "update [doc] in [project]" | Edit + `updated: YYYY-MM-DD` frontmatter |
| Promote inbox | "promote to project" | Move + update frontmatter + rename |
| List projects | "list projects" | Show all with status (skip _inbox) |
| Show contents | "what's in [project]" | List docs chronologically |
| Update status | "mark [project] as active" | Update all doc frontmatter |
| Validate | "check frontmatter" | Report missing/invalid fields |

**Conventions:**
- Filename: `YYYY-MM-DD-descriptive-name.md` (lowercase, hyphens)
- Links: Wikilinks `[[filename]]` (no .md, no path if same folder)
- Always add `## Related Documents` section to project docs

## Frontmatter

**Required fields:**
```yaml
---
project: project-name     # Matches folder name or "inbox"
status: planning          # planning|active|paused|completed|archived
type: brainstorm         # brainstorm|design|plan|notes|retrospective
created: YYYY-MM-DD      # File creation date
---
```

**Optional fields:**
- `updated: YYYY-MM-DD` - Added when document revised (filename stays same)
- `promoted: YYYY-MM-DD` - Added when moved from inbox to project

**Valid values:**
- **status:** planning, active, paused, completed, archived
- **type:** brainstorm, design, plan, notes, retrospective

## Core Operations

### Create New Project

**Trigger:** "save this as a new project"

1. Determine vault path from conversation context (see Configuration)
2. Ask for project name → validate (lowercase, hyphens, no spaces)
3. Create `<vault-path>/projects/<project-name>/`
4. Infer doc type from conversation (brainstorming → brainstorm, planning → plan)
5. Generate filename: `YYYY-MM-DD-<type>.md`
6. Write frontmatter with `status: planning`
7. Add empty `## Related Documents` section
8. Confirm: "Created projects/<name>/YYYY-MM-DD-<type>.md"

### Save to Inbox

**Trigger:** "save to inbox" / "quick idea"

1. Determine vault path from conversation context (see Configuration)
2. Create in `<vault-path>/projects/_inbox/`
3. Use descriptive filename from content
4. Frontmatter: `project: inbox`, `status: planning`, `type: notes`
5. Confirm creation

### Add Document to Existing Project

**Trigger:** "create a [design/plan] doc for [project-name]"

1. Search `projects/` for matching folder (support partial matches)
2. If not found → ask to clarify or create new project
3. If multiple matches → present options
4. Create new doc in project folder
5. Search project for related docs → add wikilinks inline where relevant
6. Add `## Related Documents` section with links + brief descriptions:
   ```markdown
   ## Related Documents

   - [[YYYY-MM-DD-initial-brainstorm]] - Initial exploration
   - [[YYYY-MM-DD-architecture]] - System design
   ```
7. Confirm creation + report links added

### Update Existing Document

**Trigger:** "update the [doc] in [project]"

1. Find document in project folder
2. Read current contents
3. Make requested updates
4. Add/update `updated: YYYY-MM-DD` in frontmatter
5. **Preserve filename** (creation date unchanged)
6. Confirm what changed

### Promote from Inbox

**Trigger:** "promote that note to a project" / "make this a proper project"

1. Identify inbox note from conversation context
2. Search `_inbox/` for related notes (similar topics, keywords)
3. Present related notes → ask which to include
4. Ask for project name
5. Create `projects/<project-name>/`
6. Move selected files → rename if needed (e.g., -idea.md → -initial-brainstorm.md)
7. Update frontmatter:
   - `project: inbox` → `project: <project-name>`
   - Add `promoted: YYYY-MM-DD`
   - Update `type` if needed (ask user or infer)
8. Confirm with list of moved files

### List Projects

**Trigger:** "list projects" / "show me all projects"

1. Determine vault path from conversation context (see Configuration)
2. Read `<vault-path>/projects/` (skip `_inbox/`)
3. For each project, read one doc to get status
4. Sort by status: active → planning → paused → completed → archived
5. Show count of documents per project

**Output:**
```
Active Projects:
- obsidian-integration (3 documents)

Planning:
- another-project (1 document)
```

### Show Project Contents

**Trigger:** "what's in [project]" / "show me [project]"

1. Find project folder
2. List all documents with types and statuses from frontmatter
3. Present chronologically

**Output:**
```
obsidian-integration (status: active):
- 2025-11-07-initial-brainstorm.md (brainstorm)
- 2025-11-08-architecture-design.md (design)
- 2025-11-10-implementation-plan.md (plan)
```

### Update Project Status

**Trigger:** "mark [project] as active" / "set status to completed"

1. Find project folder
2. Read all documents
3. Update `status` field in all frontmatter
4. Confirm count of documents updated

### Validate Frontmatter

**Trigger:** "check [project] frontmatter" / "validate frontmatter"

1. Find project folder → read all documents
2. Check each has: project, status, type, created
3. Verify `project` matches folder name
4. Verify `status` in valid values
5. Verify `type` in valid values
6. Verify dates are YYYY-MM-DD format
7. Report issues found

**Auto-validate before creating any file.**

## Structure & Naming

**Directory:**
```
<vault-path>/projects/
  _inbox/                    # Quick captures
  project-name/              # One folder per project
    YYYY-MM-DD-desc.md
```

**Note:** `<vault-path>` is determined from "Primary vault:" in conversation context (see Configuration section).

**Naming rules:**
- **Files:** `YYYY-MM-DD-descriptive-name.md` (lowercase, hyphens, concise)
- **Projects:** `project-name` (lowercase, hyphens, matches folder)
- **No spaces or underscores**

**Examples:**
- `obsidian-integration/2025-11-07-initial-brainstorm.md`
- `api-refactoring/2025-11-08-design-doc.md`

## Linking

**Internal:** `[[YYYY-MM-DD-filename]]` (no .md, no path if same folder)
**External:** `[text](url)`

**Always add to project docs:**
```markdown
## Related Documents

- [[YYYY-MM-DD-brainstorm]] - Brief description
- [[YYYY-MM-DD-design]] - Brief description
```

**Auto-linking:**
- Add inline wikilinks where contextually relevant
- Search vault when creating new docs
- Link to related project docs in Related Documents section

## Pre-flight Checks

**Before ANY file operation:**
- [ ] Path exists or can be created
- [ ] Filename matches `YYYY-MM-DD-name.md`
- [ ] Frontmatter has: project, status, type, created
- [ ] Dates are `YYYY-MM-DD` format
- [ ] Status/type are valid values (see Frontmatter section)

**Before updates:**
- [ ] File exists → read current contents
- [ ] Preserve creation date in filename (only update frontmatter)

## Common Mistakes

| Problem | Solution |
|---------|----------|
| Project not found | Search partial matches → offer to create → list available |
| Invalid frontmatter | Report issue → fix before proceeding |
| File exists | Ask to update in-place or use different filename |
| Permission denied | Report error → suggest checking vault path in user's ~/.claude/CLAUDE.md |
| Vault path not found | Check for "Primary vault:" in conversation context → use default ~/Obsidian/vault if not found |
| Wrong date in filename | Preserve creation date (filename) when updating → only change frontmatter `updated` |

## Example

**User:** "Save this brainstorm as a new project called obsidian-integration"
**You:** Create `projects/obsidian-integration/2025-11-07-initial-brainstorm.md` with frontmatter

**User:** "Create a design doc for obsidian-integration"
**You:** Create `2025-11-08-architecture-design.md`, link to `[[2025-11-07-initial-brainstorm]]`

**User:** "Promote that git-worktrees note from inbox to a project"
**You:**
1. Found `_inbox/2025-11-07-git-worktrees-idea.md`
2. Create `projects/git-worktrees/`
3. Move and rename → `2025-11-07-initial-brainstorm.md`
4. Update frontmatter: `project: git-worktrees`, add `promoted: 2025-11-08`
