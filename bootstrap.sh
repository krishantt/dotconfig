#!/usr/bin/env bash
# Bootstraps a new macOS machine from this repo, which is meant to be
# checked out directly *as* ~/.config:
#
#   git clone git@github.com:krishantt/dotconfig.git ~/.config
#   cd ~/.config && ./bootstrap.sh
#
# What it does, in order:
#   1. Installs Homebrew if missing
#   2. `brew bundle` — casks only (Brewfile)
#   3. Installs mise if missing, then `mise install` — every CLI tool
#      pinned in mise/config.toml
#   4. Installs the uv-managed Python CLI tools (uv/tools.txt)
#   5. Symlinks ~/.zshrc -> zsh/.zshrc
#
# Secrets (~/.zshrc.local) are NOT part of this repo and are not created
# here — copy that file over from your old machine (or a password manager)
# separately; zsh/.zshrc sources it if present and no-ops if it's absent.

set -euo pipefail

DOTCONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTCONFIG_DIR"

echo "==> dotconfig bootstrap starting in $DOTCONFIG_DIR"

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed"
fi

# 2. Casks
echo "==> Installing casks from Brewfile..."
brew bundle --file="$DOTCONFIG_DIR/Brewfile"

# 3. mise + all pinned CLI tools
if ! command -v mise >/dev/null 2>&1; then
  echo "==> Installing mise..."
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"
echo "==> Installing tools pinned in mise/config.toml..."
# Relies on this repo being checked out as ~/.config, mise's default global
# config dir — mise/config.toml is picked up with no extra flags.
mise install

# mise's shims dir needs to be on PATH for the uv step below, and uv itself
# comes from mise (it's pinned in mise/config.toml, not brew).
export PATH="$HOME/.local/share/mise/shims:$PATH"

# 4. uv-managed Python CLI tools
if command -v uv >/dev/null 2>&1; then
  echo "==> Installing uv tool packages from uv/tools.txt..."
  grep -vE '^\s*(#|$)' "$DOTCONFIG_DIR/uv/tools.txt" | while read -r pkg; do
    uv tool install "$pkg"
  done
else
  echo "!! uv not found on PATH after mise install — skipping uv tool step" >&2
fi

# 5. Symlink .zshrc into place
if [ ! -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
  ln -sf "$DOTCONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
  echo "==> Symlinked ~/.zshrc -> $DOTCONFIG_DIR/zsh/.zshrc"
else
  echo "!! ~/.zshrc already exists and is a real file — not overwriting." >&2
  echo "   Back it up and re-run, or manually: ln -sf $DOTCONFIG_DIR/zsh/.zshrc ~/.zshrc" >&2
fi

cat <<'EOF'

==> Done.

Remaining manual steps:
  - Copy your secrets file to ~/.zshrc.local (tokens etc. — never tracked here)
  - Open a new shell (or `exec zsh`) to pick everything up
EOF
