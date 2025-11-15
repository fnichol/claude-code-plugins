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

## Location Resolution

**Determine target location for document operations:**

### Resolution Algorithm

```
When creating document:
  If user explicitly specifies location:
    Use specified location
  Else if Local docs configured:
    If document type in [design, plan]:
      → Local docs directory
    Else:
      → Vault project
  Else:
    → Vault project (default)
```

### Document Type Categories

**Implementation docs** (go to local when Local docs configured):
- `design` - Architecture and technical design
- `plan` - Implementation tasks and roadmaps

**Exploratory docs** (always go to vault):
- `brainstorm` - Initial idea exploration
- `notes` - Working notes and observations
- `retrospective` - Post-completion reflections

### Location Override Examples

**Explicit overrides (user specifies location):**
- "save this design to the vault" → vault even if local docs enabled
- "create a plan in docs/" → local even without local docs config
- "save to inbox" → always vault _inbox

**Natural routing (no location specified):**
- "create a design doc" + Local docs configured → local docs/
- "create a design doc" + no Local docs → vault
- "save this brainstorm" + Local docs configured → vault (exploratory)
- "save this brainstorm" + no Local docs → vault

### Location-Specific Conventions

**Vault documents:**
- Filename: `YYYY-MM-DD-descriptive-name.md` (lowercase, hyphens)
- Frontmatter: Required (project, status, type, created)
- Linking: Wikilinks `[[filename]]`
- Updates: Add `updated: YYYY-MM-DD` to frontmatter

**Local documents:**
- Filename: Flexible (adapt to existing or use simple names like `architecture.md`)
- Frontmatter: Optional (not required)
- Linking: Relative markdown links `[text](./file.md)`
- Updates: Rely on git history (no frontmatter dates)

## Local Document Operations

**When `Local docs:` configured, enable operations in local directory:**

### Style Adaptation

**Detect existing project style (default behavior):**
1. Read 1-3 existing documents from local docs directory
2. Analyze:
   - Filename patterns (kebab-case, snake_case, PascalCase, date-prefixed, etc.)
   - Heading structure (ATX vs Setext, title format)
   - Frontmatter presence and format
   - Overall tone and structure
3. Match detected style in new documents

**Override with standard template:**
- If `Documentation style: standard` in CLAUDE.local.md
- Use consistent template regardless of existing docs

**Fallback to standard:**
- If local docs empty or unreadable
- Warn: "Couldn't detect local style, using standard template"

### GitHub Remote Detection

**Purpose:** Create portable links from vault docs to local docs

**Detection process:**
1. Parse `.git/config` in working directory
2. Look for `[remote "..."]` sections with `url` containing `github.com`
3. Extract: `org/repo` from URL patterns:
   - `https://github.com/org/repo.git`
   - `git@github.com:org/repo.git`
4. Determine default branch:
   - Check `.git/refs/remotes/origin/HEAD`
   - Common: `main` or `master`

**Link construction:**
`https://github.com/<org>/<repo>/blob/<branch>/docs/<filename>.md`

**When to skip linking:**
- Non-GitHub remote (GitLab, Bitbucket, self-hosted)
- No remote configured
- Cannot parse remote URL

**Multiple remotes:**
- Prefer `origin` if present
- Otherwise use first GitHub remote found

### Creating Local Documents

**Process for local doc creation:**

**Step 1:** Determine filename
- Adapt to existing style if detected
- Examples: `architecture.md`, `api-design.md`, `database-schema.md`

**Step 2:** Detect related vault docs
- Search vault index for related documents
- Match by project name, keywords, document type

**Step 3:** Create document
- Apply adapted style or standard template
- Add optional frontmatter if existing docs use it
- Include content based on user's request

**Step 4:** Add Related Documents section
- Link to related local docs: `[Architecture](./architecture.md)`
- Link to related vault docs via GitHub URL (if detected):
  ```markdown
  ## Related Documents

  - [API Design](./api-design.md) - REST API specification
  - [Initial Brainstorm](https://github.com/org/repo/blob/main/docs/brainstorm.md) - Early ideas
  ```

**Step 5:** Confirm creation
- "Created `docs/design.md` matching project style"
- List any links added

### Updating Local Documents

**Process:**
1. Locate document in local docs directory
2. Read current contents
3. Apply requested changes
4. Do not modify filename (preserve name)
5. Do not add frontmatter dates (rely on git)
6. Confirm changes: "Updated `docs/architecture.md`"

### Searching Local Documents

**Combine with vault search:**
- "show me design docs" → search vault index + scan local docs
- Report both locations: "Found in vault: ..., Found in docs/: ..."
- Let user disambiguate if multiple matches

**List all docs:**
- Combine vault index with local directory scan
- Show location for each: `[vault]` or `[local]`

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

**Check for project linking:**
- If CLAUDE.local.md exists with `Vault project:` → use that project name as suggestion
- Otherwise → ask for project name

1. Determine vault path from conversation context (see Configuration)
2. Ask for project name → validate (lowercase, hyphens, no spaces)
3. Create `<vault-path>/projects/<project-name>/`
4. Infer doc type from conversation (brainstorming → brainstorm, planning → plan)
5. Apply location resolution:
   - If Local docs configured AND type in [design, plan] → create in local docs
   - Otherwise → create in vault projects/<name>/
6. Generate filename:
   - Vault: `YYYY-MM-DD-<type>.md`
   - Local: adapt to style or use `<type>.md`
7. Write frontmatter (vault only) with `status: planning`
8. Add `## Related Documents` section
9. Confirm: "Created projects/<name>/YYYY-MM-DD-<type>.md" or "Created docs/<type>.md"

### Save to Inbox

**Trigger:** "save to inbox" / "quick idea"

1. Determine vault path from conversation context (see Configuration)
2. Create in `<vault-path>/projects/_inbox/`
3. Use descriptive filename from content
4. Frontmatter: `project: inbox`, `status: planning`, `type: notes`
5. Confirm creation

### Add Document to Existing Project

**Trigger:** "create a [design/plan] doc for [project-name]"

1. Check for CLAUDE.local.md with matching project name
2. If not found in config, search `projects/` for matching folder
3. If not found → ask to clarify or create new project
4. If multiple matches → present options
5. Apply location resolution (see Location Resolution section):
   - If Local docs configured AND type in [design, plan] → create in local docs
   - Otherwise → create in vault project folder
6. Create new doc in resolved location
7. Search both vault and local for related docs
8. Add inline wikilinks where relevant (vault) or markdown links (local)
9. Add `## Related Documents` section with links:
   - Vault docs: `[[YYYY-MM-DD-filename]]`
   - Local docs: `[Title](./filename.md)`
   - Cross-location: GitHub URL if detected
10. Confirm creation + report links added

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
3. If CLAUDE.local.md configured, include linked project prominently
4. For each project, read one doc to get status
5. Sort by status: active → planning → paused → completed → archived
6. Show count of documents per project
7. If Local docs configured, show local doc count too

**Output:**
```
Active Projects:
- obsidian-integration (3 vault docs, 2 local docs) [*linked]

Planning:
- another-project (1 vault doc)
```

[*linked] = configured in CLAUDE.local.md

### Show Project Contents

**Trigger:** "what's in [project]" / "show me [project]"

1. Find project folder in vault
2. If CLAUDE.local.md links this project, also scan local docs
3. List all documents with types and statuses from frontmatter (vault)
4. List all documents from local docs (if configured)
5. Present by location, chronologically within each

**Output:**
```
obsidian-integration (status: active):

Vault documents:
- 2025-11-07-initial-brainstorm.md (brainstorm)
- 2025-11-10-retrospective.md (retrospective)

Local documents:
- architecture.md (design)
- implementation-plan.md (plan)
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
