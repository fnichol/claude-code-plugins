# Obsidian Project Linking Verification

This document provides a comprehensive checklist for manually verifying the project linking feature implementation.

## Test Environment Setup

### Test Project 1: Vault-Only Configuration

```bash
mkdir -p /tmp/test-vault-only
cd /tmp/test-vault-only
cat > CLAUDE.local.md <<'EOF'
# Obsidian Project
Vault project: `test-vault-only`
EOF
```

### Test Project 2: Dual Location Configuration

```bash
mkdir -p /tmp/test-dual-location/docs
cd /tmp/test-dual-location
cat > CLAUDE.local.md <<'EOF'
# Obsidian Project
Vault project: `test-dual-location`
Local docs: `./docs`
EOF

# Create sample doc for style detection
cat > docs/architecture.md <<'EOF'
# Architecture Overview

This document describes the system architecture.

## Components

Details here.
EOF
```

### Test Project 3: GitHub Linking Configuration

```bash
mkdir -p /tmp/test-github-links/docs
cd /tmp/test-github-links
git init
git remote add origin https://github.com/test-user/test-repo.git

cat > CLAUDE.local.md <<'EOF'
# Obsidian Project
Vault project: `test-github-project`
Local docs: `./docs`
EOF
```

### Test Project 4: Style Override Configuration

```bash
mkdir -p /tmp/test-style-override/docs
cd /tmp/test-style-override

# Create docs with PascalCase naming
cat > docs/ApiDesign.md <<'EOF'
# API Design

Documentation using PascalCase naming convention.
EOF

cat > docs/DatabaseSchema.md <<'EOF'
# Database Schema

Schema documentation.
EOF

cat > CLAUDE.local.md <<'EOF'
# Obsidian Project
Vault project: `test-style-override`
Local docs: `./docs`
Documentation style: standard
EOF
```

## Verification Checklist

### Configuration Detection

#### CLAUDE.local.md Parsing
- [ ] `Vault project:` field detected correctly
- [ ] Project name extracted without backticks
- [ ] `Local docs:` field detected when present
- [ ] Path resolved relative to working directory
- [ ] `Documentation style:` field detected when present
- [ ] Missing fields gracefully ignored

#### Configuration Precedence
- [ ] CLAUDE.local.md overrides project-specific settings
- [ ] ~/.claude/CLAUDE.md provides vault path
- [ ] Defaults applied when not configured

### Startup Behavior

#### Silent Index Loading
- [ ] Session starts without output on success
- [ ] Index loads from vault project directory
- [ ] Frontmatter parsed (type, status, filename)
- [ ] Index stored in session memory

#### Startup Warnings
- [ ] Warning shown if vault path doesn't exist
- [ ] Soft warning if vault project doesn't exist
- [ ] Error shown if permission denied on vault
- [ ] Warning shown if local docs directory missing
- [ ] Session continues despite non-fatal warnings

#### Local Docs Verification
- [ ] Local docs directory verified at startup
- [ ] Warning shown if configured but missing
- [ ] No auto-creation of missing directories

### Location Resolution

#### Implementation Docs (design, plan)
- [ ] Design docs go to local when Local docs configured
- [ ] Design docs go to vault when no Local docs
- [ ] Plan docs go to local when Local docs configured
- [ ] Plan docs go to vault when no Local docs

#### Exploratory Docs (brainstorm, notes, retrospective)
- [ ] Brainstorm docs always go to vault
- [ ] Notes docs always go to vault
- [ ] Retrospective docs always go to vault
- [ ] Local docs configuration doesn't affect exploratory routing

#### Explicit Location Override
- [ ] "save this design to the vault" overrides local routing
- [ ] "create a plan in docs/" creates in local even without config
- [ ] "save to inbox" always uses vault _inbox
- [ ] User-specified locations respected

### Style Adaptation

#### Detection from Existing Docs
- [ ] Reads 1-3 existing documents from local docs
- [ ] Detects filename patterns (kebab-case, PascalCase, etc.)
- [ ] Detects heading structure (ATX vs Setext)
- [ ] Detects frontmatter presence and format
- [ ] Matches detected style in new documents

#### Documentation Style Override
- [ ] `Documentation style: standard` forces standard template
- [ ] Override applies regardless of existing docs
- [ ] Standard uses kebab-case filenames

#### Fallback Behavior
- [ ] Falls back to standard if local docs empty
- [ ] Falls back to standard if unreadable
- [ ] Warning shown when falling back

### GitHub Remote Detection

#### Remote Parsing
- [ ] Detects GitHub remotes from .git/config
- [ ] Parses HTTPS URLs: `https://github.com/org/repo.git`
- [ ] Parses SSH URLs: `git@github.com:org/repo.git`
- [ ] Extracts org/repo correctly

#### Branch Detection
- [ ] Determines default branch from .git/refs/remotes/origin/HEAD
- [ ] Falls back to common defaults (main, master)

#### Link Construction
- [ ] Constructs correct GitHub URLs
- [ ] Format: `https://github.com/org/repo/blob/branch/path/file.md`
- [ ] Uses detected default branch

#### Edge Cases
- [ ] Skips linking for non-GitHub remotes (GitLab, Bitbucket)
- [ ] Skips linking if no remote configured
- [ ] No warning for skipped linking
- [ ] Prefers `origin` when multiple remotes exist

### Local Document Operations

#### Creating Local Documents
- [ ] Filename adapts to existing style
- [ ] Frontmatter optional (adapts to existing)
- [ ] Content created based on user request
- [ ] Related Documents section added
- [ ] Related vault docs linked via GitHub URL
- [ ] Related local docs linked via relative paths
- [ ] Creation confirmed with location

#### Updating Local Documents
- [ ] Document located in local docs directory
- [ ] Current contents read before update
- [ ] Changes applied as requested
- [ ] Filename preserved (not modified)
- [ ] No frontmatter dates added (git history used)
- [ ] Update confirmed

#### Searching Local Documents
- [ ] Search combines vault index and local docs
- [ ] Results show location: [vault] or [local]
- [ ] Multiple matches reported separately
- [ ] User can disambiguate if needed

### Core Operations Integration

#### Create New Project
- [ ] Uses Vault project name from CLAUDE.local.md as suggestion
- [ ] Asks for name if not configured
- [ ] Validates project name format
- [ ] Creates vault project directory
- [ ] Applies location resolution for first doc
- [ ] Creates in vault or local based on type
- [ ] Related Documents section added
- [ ] Creation confirmed

#### Add Document to Existing Project
- [ ] Checks CLAUDE.local.md for project link
- [ ] Searches projects/ if not in config
- [ ] Asks for clarification if not found
- [ ] Presents options if multiple matches
- [ ] Applies location resolution by type
- [ ] Searches both locations for related docs
- [ ] Adds wikilinks (vault) or markdown links (local)
- [ ] Adds Related Documents section
- [ ] Reports links added

#### List Projects
- [ ] Reads projects/ directory from vault
- [ ] Skips _inbox/ directory
- [ ] Shows linked project prominently if configured
- [ ] Reads one doc per project for status
- [ ] Sorts by status (active, planning, paused, completed, archived)
- [ ] Shows vault doc count per project
- [ ] Shows local doc count if Local docs configured
- [ ] Marks linked project with indicator

#### Show Project Contents
- [ ] Finds project folder in vault
- [ ] Scans local docs if project linked via CLAUDE.local.md
- [ ] Lists vault documents with types and statuses
- [ ] Lists local documents (if configured)
- [ ] Presents by location
- [ ] Chronological order within each location

### Error Handling

#### Configuration Errors
- [ ] Missing Vault project field treated as no linking
- [ ] Invalid project name format shows suggestion
- [ ] CLAUDE.local.md precedence over CLAUDE.md (no warning)

#### Startup Errors
- [ ] Vault path not found: warning with path to check
- [ ] Vault project not found: soft warning, will create on save
- [ ] Permission denied: error with suggestion
- [ ] Local docs missing: warning with creation suggestion
- [ ] All startup errors non-blocking (session continues)

#### Operation Errors
- [ ] Ambiguous document reference shows both matches
- [ ] Asks user to specify location (vault/local)
- [ ] Vault write failure suggests local alternative
- [ ] Local write failure suggests vault alternative
- [ ] Permission errors clear and actionable

#### GitHub Detection Failures
- [ ] Non-GitHub remote: no cross-linking, no warning
- [ ] No remote: no cross-linking, no warning
- [ ] Multiple remotes: uses origin or first GitHub remote

#### Style Adaptation Failures
- [ ] Empty local docs: fallback to standard with note
- [ ] Unreadable local docs: fallback to standard with warning

### Vault-Specific Conventions

#### Filename Format
- [ ] Uses YYYY-MM-DD-descriptive-name.md format
- [ ] Lowercase letters only
- [ ] Hyphens for word separation
- [ ] Date reflects creation date

#### Frontmatter
- [ ] Required fields present (project, status, type, created)
- [ ] Valid status values (planning, active, paused, completed, archived)
- [ ] Valid type values (brainstorm, design, plan, notes, retrospective)
- [ ] Created date in YYYY-MM-DD format

#### Updates
- [ ] `updated: YYYY-MM-DD` added to frontmatter on updates
- [ ] Filename preserved (date not changed)

#### Linking
- [ ] Wikilinks used: `[[filename]]` (no .md extension)
- [ ] Internal references to other vault docs

### Local-Specific Conventions

#### Filename Format
- [ ] Flexible naming (adapts to existing style)
- [ ] Examples: architecture.md, api-design.md, deployment-plan.md
- [ ] Not date-prefixed by default

#### Frontmatter
- [ ] Optional (not required)
- [ ] Adapts to existing documents
- [ ] Omitted if existing docs don't use it

#### Updates
- [ ] Relies on git history (no frontmatter dates)
- [ ] No `updated` field added

#### Linking
- [ ] Relative markdown links: `[text](./file.md)`
- [ ] Standard markdown format

### Cross-Location Linking

#### Vault to Local
- [ ] GitHub URL constructed for local docs
- [ ] Format: `[Title](https://github.com/org/repo/blob/branch/docs/file.md)`
- [ ] Links added to Related Documents section

#### Local to Vault
- [ ] GitHub URL constructed for vault docs
- [ ] Same format as vault to local
- [ ] Portable across machines

#### Bidirectional Links
- [ ] Both directions work correctly
- [ ] Links remain valid when shared
- [ ] Work from any machine with repo access

## Test Scenarios

### Scenario 1: New User - Vault Only

**Setup:** No CLAUDE.local.md

**Test:**
1. User: "Save this as a new project"
2. User: "Create a design doc for [project]"
3. User: "List projects"

**Expected:**
- All docs created in vault
- Standard frontmatter applied
- Wikilinks used for internal references

### Scenario 2: Configured Project - Dual Location

**Setup:** CLAUDE.local.md with Vault project and Local docs

**Test:**
1. Start session (observe startup)
2. User: "Create a design doc"
3. User: "Save a brainstorm"
4. User: "List all project docs"

**Expected:**
- Silent startup (no output)
- Design doc in local docs/
- Brainstorm in vault
- Combined listing shows both locations

### Scenario 3: Style Adaptation

**Setup:** Local docs with PascalCase existing files

**Test:**
1. User: "Create an authentication design doc"
2. Verify filename matches PascalCase
3. Add `Documentation style: standard` to CLAUDE.local.md
4. User: "Create a deployment plan"
5. Verify filename uses kebab-case

**Expected:**
- First doc matches existing PascalCase
- Second doc uses standard kebab-case
- Override respected

### Scenario 4: Cross-Location Linking

**Setup:** GitHub remote configured, vault and local docs exist

**Test:**
1. User: "Create a design doc that references the brainstorm"
2. Verify GitHub URL added to design doc
3. User: "Update the brainstorm to link to the design"
4. Verify GitHub URL added to brainstorm

**Expected:**
- Portable GitHub URLs in both directions
- Links work from any machine
- Related Documents sections present

### Scenario 5: Error Handling

**Setup:** CLAUDE.local.md with missing local docs directory

**Test:**
1. Start session
2. Observe warning about missing directory
3. User: "Create a design doc"
4. Verify fallback to vault or request to create directory

**Expected:**
- Clear warning at startup
- Session continues
- Graceful handling of missing directory

### Scenario 6: Explicit Override

**Setup:** Dual location configured

**Test:**
1. User: "Create a design doc" (expect local)
2. User: "Save this design to the vault" (override)

**Expected:**
- First design in local docs/
- Second design in vault despite being implementation doc
- User intent respected

## Notes

### Manual Testing Approach

This verification is documentation-based since the skill guides Claude's behavior through prompt engineering, not code. To verify:

1. Create test environments as described above
2. Start Claude sessions in each test directory
3. Issue the commands in test scenarios
4. Observe Claude's behavior and responses
5. Verify files created in correct locations
6. Check file contents and formats

### Limitations

- Cannot run automated tests (skill is markdown, not code)
- Verification requires actual Claude sessions
- Behavior depends on Claude's interpretation of skill
- Some edge cases may require iteration

### Success Criteria

The implementation is successful if:
- All configuration scenarios work as specified
- Location resolution logic correctly routes documents
- Style adaptation detects and matches existing patterns
- GitHub linking constructs valid URLs
- Error messages are clear and actionable
- Backward compatibility maintained (vault-only still works)
- Documentation complete and accurate
