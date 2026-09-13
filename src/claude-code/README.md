
# Claude Code Setup (claude-code)

Installs the Claude Code CLI, adds the Claude Code VS Code extension, and drops a CLAUDE.md, settings.json and skills into the container

## Example Usage

```json
"features": {
    "ghcr.io/SamPUG/vscode-features/claude-code:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installCli | Install the Claude Code CLI using the official native installer | boolean | true |
| installClaudeMd | Copy the bundled CLAUDE.md to ~/.claude/CLAUDE.md | boolean | true |
| installSettings | Copy the bundled settings.json to ~/.claude/settings.json, denying the file tools access to .env files | boolean | true |
| installSkills | Copy the bundled skills to ~/.claude/skills, making them available in every project in the container | boolean | true |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/SamPUG/vscode-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
