# Obsidian Vault Integration

## Vault Location
Primary vault: `~/Obsidian/vault`

**To customize:** Add the following to your `~/.claude/CLAUDE.md` after the plugin reference:
```markdown
# Obsidian Vault Path Override
Primary vault: `~/your/actual/vault/path`
```

## Directory Structure
```
~/Obsidian/vault/projects/
  _inbox/                    # Quick captures
  <project-name>/            # One folder per project
    YYYY-MM-DD-desc.md
```

## Conventions
- **File naming:** `YYYY-MM-DD-descriptive-name.md` (lowercase, hyphens)
- **Frontmatter required:** project, status, type, created
- **Internal links:** Wikilinks `[[filename]]` (no .md extension)
- **Related Documents:** Add `## Related Documents` section to project docs
