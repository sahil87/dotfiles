# dotfiles

Public facing dotfiles configuration (without secrets)

## Setup

After cloning, run:
```bash
./setup-hooks.sh
```

This installs pre-commit hooks that use [gitleaks](https://github.com/gitleaks/gitleaks) to scan for secrets before each commit, preventing accidental credential leaks.

## Dotfiles Installation

See [stow/README.md](stow/README.md) for instructions on installing dotfiles using GNU Stow.

## SSH Key Bootstrap

See [docs/SSH-BOOTSTRAP-NOTES.md](docs/SSH-BOOTSTRAP-NOTES.md) for how to bootstrap SSH keys on a new machine using Tailscale.
