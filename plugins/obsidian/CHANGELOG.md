# Changelog

All notable changes to the Obsidian plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-11-15

### Added
- Project linking via CLAUDE.local.md configuration for automatic session awareness
- project-linking skill with comprehensive dual-location documentation management
- Dual-location routing between vault (exploratory docs) and local repository (implementation docs)
- Smart routing by document type: design/plan → local docs, brainstorm/notes/retrospective → vault
- GitHub URL linking for portable cross-location references between vault and local docs
- Style adaptation: local docs automatically match existing project conventions
- Silent startup index loading to pre-cache vault project documents
- Comprehensive integration test scenarios and infrastructure
- Manual verification documentation for testing workflows

### Changed
- Restructured vault-management skill into separate vault and project-linking skills
- README updated with project linking documentation, configuration examples, and usage patterns
- Enhanced plugin architecture to support session-aware project context
## [1.2.0] - 2025-11-10

### Added
- Configurable vault path via user's `~/.claude/CLAUDE.md` override
- Configuration section in vault-management skill explaining path resolution
- Clear instructions in README for customizing vault location

### Changed
- Vault path now defaults to generic `~/Obsidian/vault` instead of hardcoded personal path
- Plugin CLAUDE.md uses generic placeholder with override instructions
- SKILL.md operations now read vault path from conversation context
- All documentation examples use generic path placeholders

### Improved
- Plugin is now fully shareable without exposing personal paths
- User configuration cleanly separated from plugin code
- Better upgrade path - plugin updates won't overwrite personal config

## [1.1.0] - 2025-11-09

### Changed
- Restructured documentation for improved clarity
- Enhanced plugin metadata

## [1.0.0] - 2025-11-08

### Added
- Initial release of Obsidian plugin
- vault-management skill for structured document management
- Support for project organization with frontmatter
- Inbox workflow for quick captures
- Automatic wikilink generation
- File naming conventions (YYYY-MM-DD-name.md)

[2.0.0]: https://github.com/fnichol/claude-code-plugins/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/fnichol/claude-code-plugins/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/fnichol/claude-code-plugins/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/fnichol/claude-code-plugins/releases/tag/v1.0.0
