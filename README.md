# vscode-features

Personal [dev container Features](https://containers.dev/implementors/features/), published to GitHub Container Registry (GHCR), for setting up my own dev containers consistently. This repo was bootstrapped from the [devcontainers/feature-starter](https://github.com/devcontainers/feature-starter) template.

## Features

### `claude-code`

Installs the [Claude Code](https://claude.com/claude-code) CLI, adds the official Claude Code VS Code extension, and drops a `CLAUDE.md` into the container so Claude Code has my global instructions available from the first run.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/sampug/vscode-features/claude-code:1": {}
    }
}
```

| Option Id | Description | Type | Default |
|---|---|---|---|
| `installCli` | Install the Claude Code CLI using the official native installer | boolean | `true` |
| `installClaudeMd` | Copy the bundled `CLAUDE.md` to `~/.claude/CLAUDE.md` | boolean | `true` |

The `CLAUDE.md` that gets copied in lives at [`src/claude-code/CLAUDE.md`](src/claude-code/CLAUDE.md) — edit it there to change what ships to new containers.

## Repo structure

Each Feature has its own folder under `src/`, containing at least a `devcontainer-feature.json` and an `install.sh` entrypoint:

```
├── src
│   ├── claude-code
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── CLAUDE.md
...
```

An [implementing tool](https://containers.dev/supporting#tools) composites [the documented properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from `devcontainer-feature.json` and runs `install.sh` inside the container at build time. Options declared in `devcontainer-feature.json` are exported to `install.sh` as environment variables (capitalized, per [option resolution](https://containers.dev/implementors/features/#option-resolution)) — e.g. `installCli` becomes `$INSTALLCLI`.

Tests live under `test/<feature>/` and run via the `devcontainer features test` command from `@devcontainers/cli`. See [`test/claude-code/test.sh`](test/claude-code/test.sh) for the current checks.

## Versioning & publishing

Each Feature is versioned independently via the `version` field in its `devcontainer-feature.json`, following semver — see [the spec](https://containers.dev/implementors/features/#versioning).

[`release.yaml`](.github/workflows/release.yaml) runs on every push to `main` (or manually via `workflow_dispatch`) and publishes each Feature under `src/` to GHCR using [`devcontainers/action`](https://github.com/devcontainers/action). It only pushes a new OCI artifact for a Feature whose `version` actually changed since the last publish — a commit that doesn't bump a feature's version is a no-op for that feature. It also regenerates each Feature's `README.md` from its `devcontainer-feature.json` and opens a PR with the update, rather than committing straight to `main`.

That last step needs **"Allow GitHub Actions to create and approve pull requests"** enabled under `Settings > Actions > General > Workflow permissions` — it's off by default on new repos, and without it the doc-update step fails with `GraphQL: GitHub Actions is not permitted to create or approve pull requests`.

[`test.yaml`](.github/workflows/test.yaml) runs the tests under `test/` on every push to `main`, on pull requests, and manually. [`validate.yml`](.github/workflows/validate.yml) lints every `devcontainer-feature.json` on pull requests.

Published GHCR packages default to `private`. To use a Feature in another `devcontainer.json` without extra auth setup, mark its package `public` from the package's settings page on GitHub (`https://github.com/users/<owner>/packages/container/<repo>%2F<featureName>/settings`).
