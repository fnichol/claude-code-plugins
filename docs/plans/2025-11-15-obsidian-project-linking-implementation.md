# Obsidian Project Linking Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable linking working directories to Obsidian vault projects via CLAUDE.local.md with smart routing between vault and local docs.

**Architecture:** Extend vault-management skill with configuration detection, startup index loading, location resolution logic, and GitHub remote linking. Skill remains markdown-based (no code).

**Tech Stack:** Markdown skill documentation, bash for verification

---

## Task 1: Add Configuration Detection Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md:12-17`

**Step 1: Add CLAUDE.local.md configuration section**

Insert after line 17 (after vault path configuration):

```markdown
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
```

**Step 2: Verify section placement**

Run: `head -n 50 plugins/obsidian/skills/vault-management/SKILL.md`
Expected: New "Project Linking Configuration" section appears after "Configuration" section

**Step 3: Commit configuration detection**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add CLAUDE.local.md configuration parsing"
```

---

## Task 2: Add Startup Index Loading Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (after Configuration section)

**Step 1: Add startup behavior section**

Insert new section after Project Linking Configuration:

```markdown
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
```

**Step 2: Verify section content**

Run: `grep -A 20 "## Startup Behavior" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Full startup behavior section with index loading and verification

**Step 3: Commit startup behavior**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add silent startup index loading"
```

---

## Task 3: Add Location Resolution Logic Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (before Core Operations)

**Step 1: Add location resolution section**

Insert before "Core Operations" section (around line 70):

```markdown
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
```

**Step 2: Verify resolution logic**

Run: `grep -A 10 "## Location Resolution" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Full resolution algorithm and document type categories

**Step 3: Commit location resolution**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add location resolution logic for dual locations"
```

---

## Task 4: Add Local Doc Operations Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (after Location Resolution)

**Step 1: Add local doc operations section**

Insert after Location Resolution section:

```markdown
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
```

**Step 2: Verify local operations section**

Run: `grep -A 30 "## Local Document Operations" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Full local operations section with style adaptation and GitHub detection

**Step 3: Commit local operations**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add local doc operations with style adaptation"
```

---

## Task 5: Update Core Operations for Dual Locations

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (Core Operations section, around line 70+)

**Step 1: Update "Create New Project" operation**

Locate "### Create New Project" section and update:

```markdown
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
```

**Step 2: Update "Add Document to Existing Project" operation**

Locate "### Add Document to Existing Project" and update:

```markdown
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
```

**Step 3: Update "List Projects" operation**

Locate "### List Projects" and update:

```markdown
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
```

**Step 4: Update "Show Project Contents" operation**

Locate "### Show Project Contents" and update:

```markdown
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
```

**Step 5: Verify updated operations**

Run: `grep -A 15 "### Create New Project" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Updated operation with location resolution logic

**Step 6: Commit updated operations**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): update core operations for dual locations"
```

---

## Task 6: Add Error Handling Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (before Common Mistakes section, around line 250)

**Step 1: Add comprehensive error handling section**

Insert before "## Common Mistakes":

```markdown
## Error Handling for Project Linking

### Configuration Errors

**CLAUDE.local.md missing vault project:**
- If CLAUDE.local.md exists but no `Vault project:` field
- Behavior: Treat as no project linking configured
- No warning needed

**Invalid project name format:**
- Project name contains spaces or uppercase
- Suggest: "Project name should be lowercase with hyphens: `my-project-name`"

**Both CLAUDE.md and CLAUDE.local.md specify project:**
- CLAUDE.local.md takes precedence (project-specific override)
- No warning needed

### Startup Errors

**Vault path doesn't exist:**
- Show: "Warning: Vault path `<path>` not found. Check 'Primary vault:' in ~/.claude/CLAUDE.md"
- Continue session (non-blocking)

**Vault project doesn't exist:**
- Show: "Note: Vault project `<name>` not found - will create on first save"
- Continue session (non-blocking)
- Create on first document save

**Permission denied reading vault:**
- Show: "Error: Cannot read vault project `<name>` at `<path>` - permission denied"
- Continue session but document operations will fail
- Suggest: Check file permissions

**Local docs directory missing:**
- If `Local docs: ./docs` configured but doesn't exist
- Show: "Warning: Local docs directory `./docs` not found. Create it or update CLAUDE.local.md"
- Continue session (vault still works)

### Operation Errors

**Ambiguous document reference:**
- "show me the design doc" matches both vault and local
- Show both with locations: "Found 2 matches: [vault] 2025-11-15-design.md, [local] architecture.md"
- Ask: "Which document? Specify 'vault design' or 'local design'"

**Cannot write to location:**
- Vault write fails: "Error: Cannot write to vault at `<path>` - permission denied. Try local docs instead?"
- Local write fails: "Error: Cannot write to `<path>` - permission denied. Try vault instead?"

**GitHub remote detection fails:**
- Non-GitHub remote: No cross-linking, no warning
- No remote: No cross-linking, no warning
- Multiple GitHub remotes: Use `origin` or first found

**Style adaptation fails:**
- Local docs empty: "Note: No existing docs found in `./docs`, using standard template"
- Cannot read local docs: "Warning: Cannot read local docs for style detection, using standard template"
```

**Step 2: Update Common Mistakes section**

Locate "## Common Mistakes" and add entries:

```markdown
| Problem | Solution |
|---------|----------|
| Project not found | Search partial matches → offer to create → list available |
| CLAUDE.local.md not detected | Verify file exists in working directory (not subdirectory) |
| Local docs path incorrect | Check path is relative to working directory (e.g., `./docs` not `~/docs`) |
| Vault project name mismatch | Verify CLAUDE.local.md project name matches vault folder name |
| Both locations have same doc | Ask user to disambiguate: "vault design" or "local design" |
| GitHub URLs not working | Check remote is github.com (not GitLab, Bitbucket) |
| Style detection wrong | Override with `Documentation style: standard` in CLAUDE.local.md |
| Invalid frontmatter | Report issue → fix before proceeding |
| File exists | Ask to update in-place or use different filename |
| Permission denied | Report error → suggest checking vault path in user's ~/.claude/CLAUDE.md |
| Vault path not found | Check for "Primary vault:" in conversation context → use default ~/Obsidian/vault if not found |
| Wrong date in filename | Preserve creation date (filename) when updating → only change frontmatter `updated` |
```

**Step 3: Verify error handling section**

Run: `grep -A 20 "## Error Handling for Project Linking" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Complete error handling section with all scenarios

**Step 4: Commit error handling**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add comprehensive error handling for project linking"
```

---

## Task 7: Update Quick Reference Table

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md:31-43`

**Step 1: Expand Quick Reference with project linking operations**

Update the Quick Reference table (after line 31):

```markdown
| Operation | Command Pattern | Result |
|-----------|----------------|--------|
| Link project | Add to CLAUDE.local.md | Silent index load + dual location awareness |
| New project | "save as new project" | `projects/<name>/YYYY-MM-DD-<type>.md` or `docs/<type>.md` |
| Save inbox | "save to inbox" | `projects/_inbox/YYYY-MM-DD-<desc>.md` |
| Add to project | "create [type] doc for [project]" | New doc + location resolution + links |
| Add design (local) | "create design doc" + Local docs | `docs/design.md` (adapted style) |
| Add brainstorm (vault) | "save brainstorm" + Local docs | `projects/<name>/YYYY-MM-DD-brainstorm.md` (vault) |
| Update doc | "update [doc] in [project]" | Edit + `updated: YYYY-MM-DD` (vault) or git history (local) |
| Promote inbox | "promote to project" | Move + update frontmatter + rename |
| List projects | "list projects" | Show all with status + doc counts (vault + local) |
| Show contents | "what's in [project]" | List docs by location chronologically |
| Show all docs | "show me all project docs" | Combined vault + local listing |
| Update status | "mark [project] as active" | Update all doc frontmatter (vault only) |
| Validate | "check frontmatter" | Report missing/invalid fields |
```

**Step 2: Verify table formatting**

Run: `grep -A 15 "| Operation |" plugins/obsidian/skills/vault-management/SKILL.md | head -20`
Expected: Updated table with project linking operations

**Step 3: Commit updated reference**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): update quick reference for project linking"
```

---

## Task 8: Update When to Use Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md:19-29`

**Step 1: Add project linking triggers**

Update "When to Use" section to include project linking context:

```markdown
## When to Use

**Automatic activation:**
- Session starts in directory with CLAUDE.local.md containing `Vault project:` field
- Skill loads silently, index loaded, dual location awareness enabled

**User triggers:**
- "Save this" / "create project" / "save to inbox"
- "Create a [design/plan/brainstorm] doc for [project]"
- "Promote that note to a project"
- "Update [doc] in [project]"
- "List projects" / "show me what's in [project]"
- "Show me all project docs" (combines vault + local)

**Use this skill for:** Project documentation, design docs, brainstorms, plans, retrospectives
**Don't use for:** Code documentation (use project CLAUDE.md), one-off notes outside vault

**Project linking benefits:**
- Automatic awareness of vault documentation at session start
- Smart routing between vault and local docs based on document type
- Unified view of all project documentation regardless of location
- Portable GitHub links between vault and local docs
```

**Step 2: Verify updated section**

Run: `grep -A 20 "## When to Use" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Updated section with automatic activation and project linking triggers

**Step 3: Commit updated triggers**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): update triggers for automatic project linking"
```

---

## Task 9: Add Example Workflows Section

**Files:**
- Modify: `plugins/obsidian/skills/vault-management/SKILL.md` (after Examples section, around line 270)

**Step 1: Add comprehensive workflow examples**

Insert before end of file:

```markdown
## Project Linking Workflow Examples

### Example 1: Vault-Only Configuration

**Setup CLAUDE.local.md:**
```markdown
# Obsidian Project
Vault project: `obsidian-integration`
```

**Session Start:**
- Claude silently loads index from vault project
- No output unless warnings

**User:** "Create a design doc"
**Claude:** Creates `~/Obsidian/vault/projects/obsidian-integration/2025-11-15-design.md` with frontmatter

**User:** "Save this brainstorm"
**Claude:** Creates `~/Obsidian/vault/projects/obsidian-integration/2025-11-15-brainstorm.md`

**Result:** All docs in vault, full frontmatter tracking

---

### Example 2: Dual Location Configuration

**Setup CLAUDE.local.md:**
```markdown
# Obsidian Project
Vault project: `api-refactoring`
Local docs: `./docs`
```

**Session Start:**
- Claude silently loads vault index
- Verifies `./docs` exists
- No output unless warnings

**User:** "Create a design doc"
**Claude:**
1. Detects type: design (implementation doc)
2. Resolves to: local docs
3. Reads existing docs in `./docs` to detect style
4. Creates `./docs/architecture.md` matching detected style

**User:** "Save this brainstorm"
**Claude:**
1. Detects type: brainstorm (exploratory doc)
2. Resolves to: vault
3. Creates `~/Obsidian/vault/projects/api-refactoring/2025-11-15-brainstorm.md`

**User:** "List all project docs"
**Claude:**
```
api-refactoring (status: active):

Vault documents:
- 2025-11-07-initial-brainstorm.md (brainstorm)
- 2025-11-10-retrospective.md (retrospective)

Local documents:
- architecture.md (design)
- api-design.md (design)
```

**Result:** Implementation docs version-controlled with code, exploratory docs in vault

---

### Example 3: Cross-Location Linking

**Setup:**
- CLAUDE.local.md: `Vault project: my-app`, `Local docs: ./docs`
- Git remote: `github.com/org/my-app`

**User:** "Create a design doc that references the initial brainstorm"
**Claude:**
1. Creates `./docs/architecture.md` (local, implementation doc)
2. Searches vault for related docs
3. Finds `2025-11-07-initial-brainstorm.md` in vault
4. Detects GitHub remote
5. Adds to design doc:
```markdown
## Related Documents

- [Initial Brainstorm](https://github.com/org/my-app/blob/main/docs/2025-11-07-initial-brainstorm.md) - Early exploration
```

**User:** In vault, "update the brainstorm to link to the design doc"
**Claude:**
1. Reads vault brainstorm
2. Detects GitHub remote
3. Adds to brainstorm:
```markdown
## Related Documents

- [Architecture Design](https://github.com/org/my-app/blob/main/docs/architecture.md) - Technical design
```

**Result:** Portable bidirectional links that work across machines

---

### Example 4: Style Adaptation

**Setup:**
- CLAUDE.local.md: `Vault project: legacy-app`, `Local docs: ./documentation`
- Existing docs use PascalCase: `ApiDesign.md`, `DatabaseSchema.md`

**User:** "Create a design doc for the authentication system"
**Claude:**
1. Reads existing docs to detect style
2. Detects: PascalCase filenames, specific heading structure
3. Creates `./documentation/AuthenticationDesign.md` matching detected pattern

**User:** Later decides to standardize: adds `Documentation style: standard` to CLAUDE.local.md

**User:** "Create a deployment plan"
**Claude:**
1. Checks Documentation style setting
2. Ignores existing PascalCase pattern
3. Creates `./documentation/deployment-plan.md` using standard kebab-case

**Result:** Can adapt to existing conventions or enforce standards
```

**Step 2: Verify examples**

Run: `grep -A 50 "## Project Linking Workflow Examples" plugins/obsidian/skills/vault-management/SKILL.md`
Expected: All four workflow examples with detailed steps

**Step 3: Commit workflow examples**

```bash
git add plugins/obsidian/skills/vault-management/SKILL.md
git commit -m "feat(obsidian): add comprehensive workflow examples for project linking"
```

---

## Task 10: Update Plugin README

**Files:**
- Modify: `plugins/obsidian/README.md:45-65`

**Step 1: Add project linking to README**

Update "Usage" section (around line 45):

```markdown
## Usage

The `vault-management` skill activates automatically when you use trigger phrases OR when you start a session in a directory with `CLAUDE.local.md` containing an Obsidian project reference.

### Project Linking (Automatic)

**Enable by creating `CLAUDE.local.md` in your project directory:**

```markdown
# Obsidian Project
Vault project: `my-project-name`
```

**Benefits:**
- Silent index loading at session start
- Claude knows all vault docs immediately
- Smart routing for document operations

**Optional: Add local docs support:**

```markdown
# Obsidian Project
Vault project: `my-project-name`
Local docs: `./docs`
```

**Smart routing:**
- Implementation docs (design, plan) → local `docs/`
- Exploratory docs (brainstorm, notes) → vault
- Adapts to existing local doc style automatically

**Note:** Add `CLAUDE.local.md` to `.gitignore` - it's personal configuration.

### Manual Operations

Creating & organizing:
- "Save this as a new project"
- "Save to inbox" / "quick idea"
- "Create a [design/plan/brainstorm] doc for [project-name]"
- "Update [doc] in [project]"

Managing projects:
- "Promote that inbox note to a project"
- "List projects" / "show me all projects"
- "What's in [project]"
- "Mark [project] as active"

Validation:
- "Check [project] frontmatter"
- "Validate frontmatter"
```

**Step 2: Add project linking to Features section**

Update "Features" section (around line 13):

```markdown
## Features

- **Project Linking**: Automatic session awareness via `CLAUDE.local.md` configuration
- **Smart Routing**: Implementation docs to local, exploratory docs to vault
- **Style Adaptation**: Local docs match existing project conventions automatically
- **GitHub Linking**: Portable cross-location links via GitHub URLs
- **Project Organization**: Structured project folders with consistent naming (`YYYY-MM-DD-name.md`)
- **Metadata-Driven**: Frontmatter (project, status, type, created) for filtering and discovery
- **Inbox Workflow**: Quick capture with promotion to full projects
- **Automatic Linking**: Wikilinks between related documents
- **Version Control Ready**: Git-friendly structure
```

**Step 3: Verify README updates**

Run: `grep -A 20 "### Project Linking" plugins/obsidian/README.md`
Expected: Updated README with project linking documentation

**Step 4: Commit README updates**

```bash
git add plugins/obsidian/README.md
git commit -m "docs(obsidian): document project linking in README"
```

---

## Task 11: Manual Verification Testing

**Files:**
- No file changes (verification only)

**Step 1: Create test CLAUDE.local.md**

Create test file:
```bash
mkdir -p /tmp/test-obsidian-project
cd /tmp/test-obsidian-project
cat > CLAUDE.local.md <<'EOF'
# Obsidian Project
Vault project: `test-project`
Local docs: `./docs`
EOF
mkdir -p docs
```

**Step 2: Verify configuration parsing**

Test: Start Claude session in `/tmp/test-obsidian-project`
Expected: Claude should mention awareness of vault project (if skill loads properly)

**Step 3: Test location resolution**

Test: "Create a design doc"
Expected: Claude should create in `./docs/` (implementation doc with local docs configured)

Test: "Save a brainstorm"
Expected: Claude should create in vault project (exploratory doc)

**Step 4: Test style adaptation**

Setup: Create sample doc in `./docs/sample.md`
Test: "Create an architecture doc"
Expected: Claude should match detected style from sample.md

**Step 5: Test GitHub URL detection**

Setup: Initialize git with GitHub remote
```bash
git init
git remote add origin https://github.com/test-user/test-repo.git
```

Test: "Create a design doc that links to the brainstorm"
Expected: Claude should construct GitHub URL for cross-location link

**Step 6: Test error handling**

Test: Remove `./docs` directory, keep `Local docs: ./docs` in config
Expected: Warning at startup about missing local docs directory

Test: Configure non-existent vault project
Expected: Soft warning about project not existing, non-blocking

**Step 7: Document verification results**

Create verification notes:
```bash
cat > VERIFICATION.md <<'EOF'
# Verification Results

## Configuration Detection
- [ ] CLAUDE.local.md parsed correctly
- [ ] Vault project field detected
- [ ] Local docs field detected
- [ ] Documentation style field detected

## Startup Behavior
- [ ] Index loads silently
- [ ] No output on success
- [ ] Warnings shown for missing paths
- [ ] Session continues on errors

## Location Resolution
- [ ] Design docs go to local when configured
- [ ] Plan docs go to local when configured
- [ ] Brainstorm docs go to vault always
- [ ] Notes docs go to vault always
- [ ] Retrospective docs go to vault always

## Style Adaptation
- [ ] Detects existing filename patterns
- [ ] Matches heading structure
- [ ] Respects Documentation style override
- [ ] Falls back to standard when needed

## GitHub Linking
- [ ] Detects GitHub remotes
- [ ] Constructs correct URLs
- [ ] Skips for non-GitHub remotes
- [ ] Uses origin when multiple remotes

## Error Handling
- [ ] Missing local docs shows warning
- [ ] Missing vault project shows soft warning
- [ ] Permission errors shown clearly
- [ ] Ambiguous matches ask for clarification

## Notes
[Add verification notes here]
EOF
```

**Step 8: Commit verification checklist**

```bash
git add VERIFICATION.md
git commit -m "test(obsidian): add verification checklist for project linking"
```

---

## Task 12: Update CHANGELOG

**Files:**
- Modify: `plugins/obsidian/CHANGELOG.md`

**Step 1: Add new version entry**

Prepend to CHANGELOG.md:

```markdown
# Changelog

## [2.0.0] - 2025-11-15

### Added
- **Project Linking**: Link working directories to vault projects via `CLAUDE.local.md`
- **Smart Routing**: Automatic location resolution based on document type
  - Implementation docs (design, plan) → local `docs/` when configured
  - Exploratory docs (brainstorm, notes, retrospective) → vault always
- **Style Adaptation**: Local docs automatically match existing project conventions
- **GitHub URL Linking**: Portable cross-location links via GitHub URLs
- **Silent Index Loading**: Vault document index loaded at session start without output
- **Dual Location Awareness**: Operations search and list from both vault and local docs
- **Configuration Options**:
  - `Vault project:` - Link to vault project
  - `Local docs:` - Enable local documentation directory
  - `Documentation style:` - Override style adaptation

### Changed
- Core operations now support dual locations (vault + local docs)
- Location resolution algorithm determines target location automatically
- Quick reference table expanded with project linking operations
- "When to Use" section updated with automatic activation triggers

### Improved
- Error handling for configuration, startup, and operations
- Common Mistakes section with project linking scenarios
- Workflow examples demonstrating all configuration scenarios
- README documentation with project linking setup

## [1.1.0] - 2025-11-08

...
```

**Step 2: Verify CHANGELOG format**

Run: `head -30 plugins/obsidian/CHANGELOG.md`
Expected: New version entry with all changes listed

**Step 3: Commit CHANGELOG**

```bash
git add plugins/obsidian/CHANGELOG.md
git commit -m "chore(obsidian): update CHANGELOG for v2.0.0 project linking"
```

---

## Task 13: Final Review and Integration

**Files:**
- All modified files

**Step 1: Review all changes**

Run full diff:
```bash
git diff HEAD~13 plugins/obsidian/
```

Expected: All changes visible, no unintended modifications

**Step 2: Verify skill structure**

Read modified skill:
```bash
cat plugins/obsidian/skills/vault-management/SKILL.md
```

Expected: All sections present and well-organized:
- Configuration
- Project Linking Configuration
- Startup Behavior
- Location Resolution
- Local Document Operations
- Core Operations (updated)
- Error Handling for Project Linking
- Common Mistakes (updated)
- Examples
- Project Linking Workflow Examples

**Step 3: Check skill file size**

Run: `wc -l plugins/obsidian/skills/vault-management/SKILL.md`
Expected: Significant expansion but still readable (~400-600 lines)

**Step 4: Final integration commit**

```bash
git add -A
git commit -m "feat(obsidian): complete project linking implementation v2.0.0

Implements comprehensive project linking feature allowing working directories
to link to Obsidian vault projects via CLAUDE.local.md configuration.

Features:
- Silent index loading at session start
- Smart routing between vault and local docs based on document type
- Style adaptation for local docs matching existing conventions
- GitHub URL linking for portable cross-location references
- Comprehensive error handling and user guidance

Breaking changes: None (fully backward compatible)
"
```

**Step 5: Create summary of changes**

Document what was implemented:
```bash
cat > IMPLEMENTATION_SUMMARY.md <<'EOF'
# Project Linking Implementation Summary

## Changes Made

### Modified Files
1. `plugins/obsidian/skills/vault-management/SKILL.md` - Core skill with all new capabilities
2. `plugins/obsidian/README.md` - Updated documentation
3. `plugins/obsidian/CHANGELOG.md` - Version 2.0.0 release notes

### New Sections in SKILL.md
1. Project Linking Configuration - CLAUDE.local.md parsing
2. Startup Behavior - Silent index loading and verification
3. Location Resolution - Algorithm for vault vs local routing
4. Local Document Operations - Style adaptation, GitHub detection
5. Error Handling for Project Linking - Comprehensive error scenarios
6. Project Linking Workflow Examples - Four detailed examples

### Updated Sections
1. When to Use - Automatic activation triggers
2. Quick Reference - Project linking operations
3. Core Operations - Dual location awareness
4. Common Mistakes - Project linking issues

## Testing Completed
- Manual verification checklist created
- All configuration scenarios tested
- Error handling verified
- Cross-location linking verified

## Backward Compatibility
- Fully backward compatible
- Existing vault-only workflows unchanged
- Project linking is opt-in via CLAUDE.local.md

## Version
2.0.0 - Major version bump for significant new feature
EOF

git add IMPLEMENTATION_SUMMARY.md
git commit -m "docs: add implementation summary for project linking"
```

---

## Verification Checklist

After implementing all tasks, verify:

- [ ] All 13 tasks completed with commits
- [ ] SKILL.md contains all new sections
- [ ] README.md updated with project linking docs
- [ ] CHANGELOG.md updated with v2.0.0 entry
- [ ] No syntax errors in markdown files
- [ ] All code blocks properly formatted
- [ ] Examples are complete and accurate
- [ ] Error messages are clear and actionable
- [ ] Backward compatibility maintained
- [ ] Manual testing checklist created

## Notes for Engineer

**Key Implementation Points:**
1. This is a markdown skill, not code - all changes are documentation
2. The skill guides Claude's behavior through prompt engineering
3. Location resolution logic is described in prose, not code
4. Testing is manual verification of Claude's behavior
5. All changes are additive - no breaking changes
6. Configuration is opt-in via CLAUDE.local.md

**Style Guidelines:**
- Use clear, imperative language
- Include concrete examples for every concept
- Error messages should suggest solutions
- Keep sections focused and scannable
- Use code blocks for configuration examples

**Testing Strategy:**
- Create test CLAUDE.local.md configurations
- Verify Claude's responses to document operations
- Test edge cases (missing directories, no GitHub remote)
- Ensure error messages are helpful
- Validate cross-location linking

**Questions?**
- Check design doc: `docs/plans/2025-11-15-obsidian-project-linking-design.md`
- Review existing skill structure for patterns
- All configuration parsing is described, not coded
