---
name: vault-management
description: Manage brainstorming and planning documents in Obsidian vault following established conventions
---

# Obsidian Vault Integration Skill

## Overview

This skill manages documents in an Obsidian vault using direct file system access. It enforces naming conventions, generates proper frontmatter, and maintains linking strategies for project documentation.

**Vault Location:** `~/Sync/Obsidian/fnichol`

## Core Operations

### 1. Create New Project

**When:** User says "save this as a new project" or "create a project for this"

**Process:**
1. Ask user for project name (if not provided)
2. Validate project name (lowercase, hyphens, no spaces)
3. Create `~/Sync/Obsidian/fnichol/projects/<project-name>/` directory
4. Create first document with type based on conversation context
5. Generate frontmatter with proper fields
6. Add Related Documents section (empty for first doc)
7. Confirm creation with full path

**Frontmatter template:**
```yaml
---
project: <project-name>
status: planning
type: <inferred-from-context>
created: <YYYY-MM-DD>
---
```

**Filename format:** `YYYY-MM-DD-<descriptive-name>.md`

### 2. Save to Inbox

**When:** User says "save to inbox" or "quick idea"

**Process:**
1. Create document in `~/Sync/Obsidian/fnichol/projects/_inbox/`
2. Generate frontmatter with `project: inbox`
3. Use descriptive filename based on content
4. Confirm creation

**Frontmatter template:**
```yaml
---
project: inbox
status: planning
type: notes
created: <YYYY-MM-DD>
---
```

### 3. Add Document to Existing Project

**When:** User references project by name: "create a design doc for obsidian-integration"

**Process:**
1. Search `~/Sync/Obsidian/fnichol/projects/` for matching folder
2. If not found, ask user to clarify or create new project
3. If multiple matches, ask user to clarify
4. Create new document in project folder
5. Generate frontmatter with project name
6. Search project folder for related documents
7. Add inline wikilinks where contextually relevant
8. Add Related Documents section with links to related docs
9. Confirm creation

**Related Documents section example:**
```markdown
## Related Documents

- [[2025-11-07-initial-brainstorm]] - Initial exploration
- [[2025-11-08-architecture-design]] - System design
```

### 4. Update Existing Document

**When:** User says "update the <doc> in <project>"

**Process:**
1. Find the document in project folder
2. Read current contents
3. Make requested updates
4. Add or update `updated: YYYY-MM-DD` in frontmatter
5. Preserve filename (creation date unchanged)
6. Confirm update with what changed

**Important:** Filename stays unchanged - only frontmatter `updated` field changes.

### 5. Promote from Inbox

**When:** User says "promote that note to a project" or "make this a proper project"

**Process:**
1. Identify the inbox note (from conversation context)
2. Search `_inbox/` for related notes (similar topics, keywords)
3. Present related notes to user, ask which to include
4. Ask for project name
5. Create `projects/<project-name>/` directory
6. Move selected files to new project folder
7. Rename files following convention (e.g., -idea.md → -initial-brainstorm.md)
8. Update frontmatter:
   - Change `project: inbox` to `project: <project-name>`
   - Add `promoted: YYYY-MM-DD` field
   - Update `type` if needed (ask user or infer)
   - Preserve `status`
9. Confirm promotion with list of moved files

**Frontmatter updates:**
```yaml
# Before (inbox):
---
project: inbox
status: planning
type: notes
created: 2025-11-07
---

# After (promoted):
---
project: obsidian-integration
status: planning
type: brainstorm
created: 2025-11-07
promoted: 2025-11-08
---
```

### 6. List Projects

**When:** User says "list projects" or "show me all projects"

**Process:**
1. Read `~/Sync/Obsidian/fnichol/projects/` directory
2. Skip `_inbox/` folder
3. For each project, read one document to get status
4. Present list with project names and status
5. Sort by status (active, planning, paused, completed, archived)

**Output format:**
```
Active Projects:
- obsidian-integration (3 documents)

Planning:
- another-project (1 document)
```

### 7. Show Project Contents

**When:** User says "show me what's in <project>"

**Process:**
1. Find project folder
2. List all documents with creation dates
3. Show type and status from frontmatter
4. Present chronologically

**Output format:**
```
obsidian-integration (status: planning):
- 2025-11-07-initial-brainstorm.md (brainstorm)
- 2025-11-08-architecture-design.md (design)
- 2025-11-10-implementation-plan.md (plan)
```

### 8. Update Project Status

**When:** User says "mark <project> as active" or "update status to completed"

**Process:**
1. Find project folder
2. Read all documents in project
3. Update `status` field in all frontmatter
4. Confirm how many documents updated

### 9. Search Related Vault Notes

**When:** Creating new document or user asks to find related notes

**Process:**
1. Extract key terms from conversation or document
2. Search vault for notes containing those terms
3. Present matching notes
4. Offer to add wikilinks to new document

### 10. Validate Frontmatter

**When:** User says "check <project> frontmatter" or explicitly requests validation

**Process:**
1. Find project folder
2. Read all documents
3. Check each has required fields: project, status, type, created
4. Check `project` field matches folder name
5. Check `status` is valid value
6. Check `type` is valid value
7. Check date formats are YYYY-MM-DD
8. Report any issues found

### 11. Find Project

**When:** Adding document or continuing work, need to locate project

**Process:**
1. Search `~/Sync/Obsidian/fnichol/projects/` for folder matching name
2. Support partial matches (user says "obsidian", find "obsidian-integration")
3. If multiple matches, present options
4. Return full path

### 12. Generate Project Overview

**When:** User says "create an overview for <project>"

**Process:**
1. Find project folder
2. Read all documents
3. Extract key information from each
4. Create `overview.md` or `README.md` in project folder
5. Include:
   - Project summary
   - Current status
   - List of documents with descriptions
   - Key decisions or outcomes
6. Generate frontmatter with `type: notes`

## Conventions to Enforce

### File Naming
- Format: `YYYY-MM-DD-descriptive-name.md`
- Use lowercase
- Use hyphens not spaces or underscores
- Be descriptive but concise

### Frontmatter Fields

**Required:**
- `project` - Project identifier (matches folder name or "inbox")
- `status` - One of: planning, active, paused, completed, archived
- `type` - One of: brainstorm, design, plan, notes, retrospective
- `created` - YYYY-MM-DD format

**Optional:**
- `updated` - YYYY-MM-DD (added when document revised)
- `promoted` - YYYY-MM-DD (added when promoted from inbox)

### Linking Strategy

**Internal references:** Use wikilinks `[[note-name]]`
- Omit .md extension
- Just use filename without path if in same folder
- Example: `[[2025-11-07-initial-brainstorm]]`

**External URLs:** Use markdown `[text](url)`

**Related Documents Section:**
- Add at end of document
- Use `## Related Documents` heading
- List related docs with brief description
- Use wikilinks for vault references

**Auto-linking:**
- Add inline wikilinks where contextually relevant
- Always add Related Documents section for project docs
- Search vault for relevant existing notes when creating new docs

### Project Naming
- Use lowercase
- Use hyphens to separate words
- Be descriptive but concise
- Examples: `obsidian-integration`, `api-refactoring`, `user-auth`

### Directory Structure
```
~/Sync/Obsidian/fnichol/
  projects/
    _inbox/              # Quick captures
    <project-name>/      # One folder per project
      YYYY-MM-DD-*.md
```

## Validation Rules

**Before creating any file:**
1. Validate path exists or can be created
2. Check filename follows convention
3. Verify frontmatter has required fields
4. Ensure dates are valid YYYY-MM-DD format
5. Check status and type values are valid

**Valid status values:** planning, active, paused, completed, archived
**Valid type values:** brainstorm, design, plan, notes, retrospective

**Before searching:**
1. Confirm vault path exists
2. Handle permission errors gracefully

**Before updating:**
1. Confirm file exists
2. Read current contents first
3. Preserve creation date in filename

## Error Handling

**Project not found:**
- Search for partial matches
- Offer to create new project
- List available projects

**Invalid frontmatter:**
- Report what's wrong
- Offer to fix
- Don't proceed until valid

**File already exists:**
- Ask if should update in place
- Offer different filename
- Don't overwrite without confirmation

**Permission denied:**
- Report clear error message
- Suggest checking vault path in CLAUDE.md

## Usage Examples

**Creating new project:**
```
User: "Save this brainstorm as a new project"
Skill: "What should we call this project?"
User: "obsidian-integration"
Skill: "Created projects/obsidian-integration/2025-11-07-initial-brainstorm.md"
```

**Adding to project:**
```
User: "Create a design doc for obsidian-integration"
Skill: [creates document with links to existing docs]
Skill: "Created projects/obsidian-integration/2025-11-08-architecture-design.md
  Links: [[2025-11-07-initial-brainstorm]]"
```

**Promoting from inbox:**
```
User: "Promote that git worktrees note to a project"
Skill: "Found 1 related inbox note: 2025-11-06-development-isolation.md
  Should I include it?"
User: "Yes"
Skill: "What should we call this project?"
User: "isolated-development"
Skill: "Created projects/isolated-development/
  Moved: 2025-11-07-git-worktrees-idea.md → 2025-11-07-initial-brainstorm.md"
```

## Integration with Conversations

**Context awareness:**
- Track current project in conversation
- Infer document type from conversation (brainstorming → brainstorm, planning → plan)
- Remember recently mentioned projects for quick reference

**Natural triggers:**
- "Save this" → ask where (new project, existing project, inbox)
- "Create a [type] doc" → infer type from user's words
- "[Project name]" → search for and use that project

**Confirmation messages:**
- Always confirm file creation with full path
- Report what links were added
- Show frontmatter that was generated
- Mention related documents found

## Maintenance

**Periodic checks:**
- Validate all project frontmatter on request
- Report projects with no recent activity
- Find orphaned documents (not in projects or inbox)

**Cleanup operations:**
- Archive completed projects (move to archive/ folder)
- Consolidate related inbox notes
- Update outdated status values
