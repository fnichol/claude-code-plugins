# Baseline SKILL.md for TDD Testing

## Purpose

`SKILL-baseline.md` is the vault skill (formerly vault-management) **before project linking features were added**.

This baseline version is used for **RED phase testing** in the TDD cycle to observe how agents behave WITHOUT the project linking documentation.

## What's Included (Baseline)

**Original sections (274 lines):**
- Overview
- Configuration
- When to Use
- Quick Reference
- Frontmatter
- Core Operations
- Structure & Naming
- Linking
- Related Documents
- Pre-flight Checks
- Common Mistakes
- Example

**Features covered:**
- Basic vault management (projects folder, _inbox)
- Frontmatter generation (project, status, type, created)
- YYYY-MM-DD-name.md file naming
- Wikilinks for internal linking
- Create/update/promote operations
- Project listing and status management

## What's Missing (Project Linking Features)

**Sections NOT in baseline (added in 9 commits, +454 lines):**
- Project Linking Configuration
- Startup Behavior
- Location Resolution
- Local Document Operations
- Error Handling for Project Linking
- Project Linking Workflow Examples

**Features NOT in baseline:**
- CLAUDE.local.md detection and parsing
- Silent startup index loading
- Dual-location routing (vault vs local docs)
- Document type categories (implementation vs exploratory)
- Style adaptation for local docs
- GitHub remote detection for cross-location linking
- Local docs directory support
- Enhanced error handling for project linking scenarios

**Modified sections (baseline has simpler versions):**
- Core Operations (no dual-location awareness)
- When to Use (no automatic activation)
- Quick Reference (no project linking operations)
- Common Mistakes (fewer entries)

## How to Use for Testing

### RED Phase (Baseline Testing)

Use `SKILL-baseline.md` to observe agent behavior WITHOUT project linking:

```markdown
Test Context:
- Use baseline vault skill from SKILL-baseline.md (NOT the current vault skill)
- Agents will NOT know about CLAUDE.local.md integration
- Agents will NOT route documents by type
- Agents will NOT adapt to local doc styles
- Agents will NOT use GitHub URLs for cross-location linking

This reveals natural failure modes and rationalizations.
```

### GREEN Phase (Full Feature Testing)

Switch to both skills (vault + project-linking) to verify features work:

```markdown
Test Context:
- Use vault skill from vault/SKILL.md (core operations)
- Use project-linking skill from project-linking/SKILL.md (project linking features)
- Agents SHOULD handle all project linking features correctly
- Verify against success criteria in test-scenarios.md

This confirms the feature documentation is effective.
```

## File Comparison

| File | Lines | Version | Use Case |
|------|-------|---------|----------|
| `SKILL-baseline.md` | 274 | Pre-project-linking (commit 606e14f) | RED phase testing |
| `vault/SKILL.md` + `project-linking/SKILL.md` | Split | Current with two focused skills | GREEN phase testing |
| Difference | Split into two skills | Vault operations + project linking | What we're testing |

## Version Information

**Baseline extracted from:**
- Commit: `606e14f`
- Date: Before 2025-11-15
- Description: "feat(obsidian): parameterize vault path for shareability"

**Current version includes:**
- Commits: `e113276` through `c3d76aa` (9 commits)
- Date: 2025-11-15
- Description: Project Linking v2.0 feature set

## Testing Workflow

1. **Setup:** Run `./setup-test-environment.sh`
2. **RED Phase:** Test with `SKILL-baseline.md` → document failures
3. **GREEN Phase:** Test with `SKILL.md` → verify success criteria
4. **REFACTOR:** Add counters for rationalizations → re-test
5. **Deploy:** Only push if all tests pass

See `test-scenarios.md` for complete testing instructions.

## Notes

- The baseline represents a fully functional skill (no bugs, just missing features)
- Baseline should NOT be modified during testing
- If baseline needs changes, regenerate from git (this was the original vault-management skill before the split)
- The baseline is a snapshot in time for comparison purposes
