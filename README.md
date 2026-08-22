# dotconfig

Checked out directly as `~/.config`. New machine:

```
git clone git@github.com:krishantt/dotconfig.git ~/.config
cd ~/.config && ./bootstrap.sh
```

CLI tools are pinned in `mise/config.toml` (mise) or `uv/tools.txt` (Python,
via `uv tool install`) — brew is cask-only (`Brewfile`). Secrets live in
`~/.zshrc.local`, which is never tracked here.
