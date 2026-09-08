#!/bin/sh
set -e

echo "Activating feature 'claude-code'"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# For more details, see https://containers.dev/implementors/features#user-env-var
_REMOTE_USER=${_REMOTE_USER:-root}
_REMOTE_USER_HOME=${_REMOTE_USER_HOME:-$HOME}

INSTALL_CLI=${INSTALLCLI:-true}
INSTALL_CLAUDE_MD=${INSTALLCLAUDEMD:-true}

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$INSTALL_CLI" = "true" ]; then
    if ! command -v curl >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -y
            apt-get install -y curl ca-certificates
        elif command -v apk >/dev/null 2>&1; then
            apk add --no-cache curl ca-certificates
        else
            echo "ERROR: curl is required to install the Claude Code CLI and could not be installed automatically." >&2
            exit 1
        fi
    fi

    echo "Installing the Claude Code CLI for user '$_REMOTE_USER' via the native installer..."
    su "$_REMOTE_USER" -c "curl -fsSL https://claude.ai/install.sh | bash"

    # The native installer places 'claude' under the target user's home directory
    # (typically ~/.local/bin). Symlink it onto the system PATH so it's available
    # to every user/shell in the container, not just interactive shells that source
    # the installer's rc file changes.
    CLAUDE_BIN="$_REMOTE_USER_HOME/.local/bin/claude"
    if [ ! -x "$CLAUDE_BIN" ]; then
        CLAUDE_BIN=$(find "$_REMOTE_USER_HOME" -maxdepth 4 -type f -name claude -perm -u+x 2>/dev/null | head -n1)
    fi
    if [ -n "$CLAUDE_BIN" ] && [ -x "$CLAUDE_BIN" ]; then
        ln -sf "$CLAUDE_BIN" /usr/local/bin/claude
    else
        echo "WARNING: could not locate the installed 'claude' binary to link onto PATH." >&2
    fi
fi

if [ "$INSTALL_CLAUDE_MD" = "true" ]; then
    echo "Installing CLAUDE.md into $_REMOTE_USER_HOME/.claude..."
    mkdir -p "$_REMOTE_USER_HOME/.claude"
    cp "$FEATURE_DIR/CLAUDE.md" "$_REMOTE_USER_HOME/.claude/CLAUDE.md"
    chown -R "$_REMOTE_USER" "$_REMOTE_USER_HOME/.claude"
fi

echo "Done installing feature 'claude-code'"
