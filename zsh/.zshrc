# secrets/tokens live in ~/.zshrc.local (untracked, not in dotconfig)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"
export PATH="/Users/krishtimil/.local/bin:$PATH"
export PATH="/Users/krishtimil/.bun/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/krishtimil/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# mise last so its shims win over anything above (tool versions/replacements)
eval "$("$HOME/.local/bin/mise" activate zsh)"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

alias cl="clear"
alias tf="tofu"

c() {
  z "$1" && zed .
}

up() {
  echo "🔄 Updating Homebrew..."
  brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup --prune=7

  echo "🛠️ Updating mise tools..."
  GITHUB_TOKEN="$(gh auth token)" mise upgrade 2>&1 | grep -v 'mise WARN.*minimum_release_age'

  echo "🐍 Updating uv tools..."
  uv tool upgrade --all
  uv cache prune

  echo "🖥️ Checking for macOS software updates..."
  softwareupdate -ia
}

alias al="aws sso login --profile lelapa-readonly"
alias al-write="aws sso login --profile lelapa"

if [ -z "$HERDR_ENV" ] && { [ "$TERM_PROGRAM" = "ghostty" ] || [ -n "$KITTY_WINDOW_ID" ]; }; then
  herdr
fi
