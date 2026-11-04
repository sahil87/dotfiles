# dotfiles

Public dotfiles (no secrets): shell, git, SSH client and tool configs, installed with GNU Stow, plus the
scripts a new machine runs before it can reach anything private.

## New machine

Start with [docs/SSH-BOOTSTRAP-NOTES.md](docs/SSH-BOOTSTRAP-NOTES.md): it makes the machine reachable from
a trusted machine (SSH key, Tailscale). The full setup guides live in the private `lifetracker` repo
(`guides/`), which the machine can read once it has GitHub access.

## Layout

- `stow/packages/`: the dotfiles, one stow package per tool. See [stow/README.md](stow/README.md).
- `scripts/`: bootstrap scripts (`authorize-ss-key.sh`, `setup-tailscale.sh`, SSH key/config pulls) and the
  macOS Brewfile (`scripts/macinstall/`).

## Contributing to this repo

After cloning, run:

```bash
./setup-hooks.sh
```

This installs a [gitleaks](https://github.com/gitleaks/gitleaks) pre-commit hook that blocks commits
containing secrets.
