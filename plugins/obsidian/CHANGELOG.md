# Changelog

All notable changes to the Obsidian plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.2.0]: https://github.com/fnichol/claude-code-plugins/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/fnichol/claude-code-plugins/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/fnichol/claude-code-plugins/releases/tag/v1.0.0
