# Obsidian Project Linking Design

## Overview

Link a working directory to an Obsidian vault project through `CLAUDE.local.md` configuration. Claude gains awareness of project documentation in both the vault and optionally in a local `docs/` directory, enabling smart routing of documentation operations based on document type.

## Goals

- Link working directories to vault projects for automatic documentation awareness
- Enable optional local `docs/` directory for version-controlled documentation
- Smart routing: implementation docs to local, exploratory docs to vault
- Maintain portability across machines (no filesystem path dependencies)
- Personal configuration (not imposed on collaborators)

## Configuration Format

The feature adds project-specific vault integration through `CLAUDE.local.md` (gitignored, personal):

```markdown
# Obsidian Project
Vault project: `my-project-name`
```

This minimal config:
- Links working directory to vault project
- Defaults all documentation to vault location
- Loads document index silently at session start
- Warns without blocking if vault project doesn't exist

### Optional Local Docs

```markdown
# Obsidian Project
Vault project: `my-project-name`
Local docs: `./docs`
```

`Local docs:` enables smart routing:
- **Implementation docs** (design, plan) → local `docs/`
- **Exploratory docs** (brainstorm, notes, retrospective) → vault
- Local docs adapt to existing project style

### Optional Style Override

```markdown
Documentation style: standard
```

Force standard templates instead of adapting to existing docs.

### Why `CLAUDE.local.md`?

- Personal preference (not imposed on collaborators)
- Gitignored (no shared state)
- Each person chooses their own vault project name
- Works independently or alongside shared `CLAUDE.md`

## Session Startup Behavior

When Claude starts in a directory with `CLAUDE.local.md` containing an Obsidian project reference:

### 1. Load vault-management skill

- Loads automatically
- Gains awareness of both vault and local doc locations
- Silent unless error occurs

### 2. Read vault path from context

- Uses "Primary vault:" from `~/.claude/CLAUDE.md` (already established pattern)
- Expands `~` to home directory
- Default: `~/Obsidian/vault` if not configured

### 3. Load document index from vault project

- Read `<vault-path>/projects/<project-name>/`
- Extract filename, type, and status from each document's frontmatter
- Store in memory for session
- **Silent success** - no output to user
- **Visible warnings** only if:
  - Vault path doesn't exist
  - Project folder doesn't exist (soft warning: "will create on first save")
  - Permission denied reading project folder

### 4. Check for local docs directory

- Verify directory exists if `Local docs:` configured
- Warn if specified but not found
- Respect project structure (no automatic creation)

**Result:** Claude knows the documentation landscape without cluttering your screen.

## Document Operations

### Creating Documents - Smart Routing

**Scenario 1: Vault-only config** (no `Local docs:` specified)
- ALL document types → vault project
- "create a design doc" → `<vault>/projects/<project>/YYYY-MM-DD-design.md`
- "save this brainstorm" → `<vault>/projects/<project>/YYYY-MM-DD-brainstorm.md`

**Scenario 2: Local docs enabled** (`Local docs: ./docs`)
- **Implementation docs** (design, plan) → `./docs/`
  - Adapt to existing doc style/format/naming
  - No date prefix required
  - No frontmatter required
  - Example: `./docs/architecture.md`, `./docs/api-design.md`
- **Exploratory docs** (brainstorm, notes, retrospective) → vault
  - Standard vault conventions (frontmatter, date prefix)
  - Example: `<vault>/projects/<project>/YYYY-MM-DD-initial-brainstorm.md`

**Scenario 3: Override with natural language**
- "save this design to the vault" → vault even if local docs enabled
- "create a plan in docs/" → local even without local docs config

### Reading Documents

- Search both locations for documents
- Use pre-loaded vault index
- Scan local `docs/` when needed
- Read full content on demand only

### Updating Documents

- Preserve location (vault stays vault, local stays local)
- Vault docs: add `updated: YYYY-MM-DD` to frontmatter
- Local docs: rely on git history for timeline

## Cross-Location Linking

### From vault docs → local docs

- Create links only if Git remote is GitHub
- Construct GitHub URLs: `https://github.com/org/repo/blob/main/docs/file.md`
- Parse `.git/config` to detect `github.com` remotes
- Use default branch name from Git config (usually `main` or `master`)
- Require GitHub remote for linking

### From local docs → vault

- Avoid automatic linking to preserve portability
- Local docs are version-controlled and portable
- Vault location varies by machine

### Within same location

- Vault → vault: wikilinks `[[filename]]` (existing convention)
- Local → local: relative markdown links `[text](./other-doc.md)`

### Example vault doc with GitHub link

```markdown
## Related Documents

- [[2025-11-10-initial-brainstorm]] - Initial exploration
- [Architecture Design](https://github.com/org/repo/blob/main/docs/architecture.md) - Implementation plan
```

### Why GitHub URLs?

- Portable across machines
- Work even if repo not cloned locally
- Point to canonical source of truth
- No broken filesystem paths

## Skill Modifications

### Changes to vault-management skill

#### 1. New configuration detection

- Read `CLAUDE.local.md` when present in working directory
- Parse `Vault project:`, `Local docs:`, and `Documentation style:` fields
- Store as session context alongside vault path from `~/.claude/CLAUDE.md`

#### 2. Startup index loading

- New operation: "Load project index" (silent)
- Read all docs in vault project folder
- Extract metadata: filename, type (from frontmatter), status (from frontmatter)
- Cache in memory for duration of session
- Handle missing project gracefully (soft warning)

#### 3. Location resolution logic

```
When creating document:
  If user specifies location explicitly → use that
  Else if Local docs configured:
    If type in [design, plan] → local docs/
    Else → vault
  Else → vault (default)
```

#### 4. Local doc operations

- New: "Adapt to local style" - read 1-3 existing docs, match format
- New: "Use standard template" - override when `Documentation style: standard`
- Relaxed conventions: no frontmatter requirement, flexible naming
- New: "Detect GitHub remote" - parse `.git/config` for linking

#### 5. Updated search/read operations

- Check both locations when searching for docs
- "show me the design doc" → search both, return matches
- "list all docs" → combine vault index + local directory scan

## Error Handling & Edge Cases

### Missing vault project

- Startup: Soft warning "Vault project `name` not found - will create on first save"
- First document save: Create project folder with standard structure
- No blocking - session continues normally

### Missing local docs directory

- Warn at startup if `Local docs: ./docs` specified but doesn't exist
- Respect project structure (no automatic creation)
- Suggest: "Create ./docs or update CLAUDE.local.md"

### Permission errors

- Show visible error with path if vault cannot be read
- Show visible error and suggest alternative if write fails
- Always report errors

### Ambiguous requests

- "show me the design doc" matches both vault and local → show both with locations
- "update the plan" matches multiple → ask which one
- Let user disambiguate with "the vault design" or "the local plan"

### GitHub remote detection fails

- Skip cross-linking for non-GitHub remotes (GitLab, Bitbucket, self-hosted)
- Skip cross-linking if no remote configured
- Use `origin` if present with multiple GitHub remotes, otherwise use first found

### Style adaptation fails

- Local docs/ empty or no readable files → fall back to standard template
- Can't parse existing docs → fall back to standard template
- Warn user: "Couldn't detect local style, using standard template"

### Configuration conflicts

- Both `CLAUDE.md` and `CLAUDE.local.md` specify vault project → local overrides
- Invalid paths in config → error with suggestion to check config

## Implementation Notes

- Vault path resolution uses existing "Primary vault:" pattern from plugin's CLAUDE.md
- Document type categorization: design and plan are "implementation", brainstorm/notes/retrospective are "exploratory"
- Local docs use flexible conventions to respect existing project practices
- Vault docs continue using strict conventions (frontmatter, date-prefixed naming)
- GitHub URL construction requires parsing .git/config and detecting default branch
- Silent loading reduces noise while maintaining error visibility
