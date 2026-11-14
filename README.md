# dotfiles

Public bootstrap scripts (no secrets): what a new machine runs before it can reach anything private. The
dotfiles themselves (shell, git, SSH client and tool configs, installed with GNU Stow) moved to the private
`lifetracker` repo, `stow/`, on 2026-11-06.

## New machine

Start with [docs/SSH-BOOTSTRAP-NOTES.md](docs/SSH-BOOTSTRAP-NOTES.md): it covers initial access, Tailscale
and the first `lifetracker` checkout for each machine class (trusted Mac, trusted VM, dev, edge). The full
setup guides live in the private `lifetracker` repo (`guides/`).

## Layout

- `scripts/`: bootstrap scripts (`authorize-ss-key.sh`, `setup-tailscale.sh`, SSH key/config pulls). The
  macOS Brewfile is in `lifetracker` (`scripts/macinstall/`).
- `docs/`: one bootstrap guide through the first private checkout.

## Contributing to this repo

After cloning, run:

```bash
./setup-hooks.sh
```

This installs a [gitleaks](https://github.com/gitleaks/gitleaks) pre-commit hook that blocks commits
containing secrets.
