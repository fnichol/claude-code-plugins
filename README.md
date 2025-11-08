# Fletcher's Claude Code Plugins

Personal collection of Claude Code plugins.

## Installation

Add this marketplace:

```
/plugin marketplace add fnichol/claude-code-plugins
```

Then browse and install plugins:

```
/plugin install <plugin-name>@fnichol-plugins
```

## Available Plugins

- **obsidian** - Obsidian vault integration for Claude Code

## Development

Plugins are stored in `plugins/` with standard Claude Code plugin structure.
Each plugin maintains its complete directory layout:

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    ├── agents/
    ├── skills/
    └── README.md
```

To add a plugin:
1. Copy or create plugin in `plugins/new-plugin/`
2. Add entry to `.claude-plugin/marketplace.json`
3. Commit and push
