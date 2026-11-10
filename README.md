# dotfiles

Public bootstrap scripts (no secrets): what a new machine runs before it can reach anything private. The
dotfiles themselves (shell, git, SSH client and tool configs, installed with GNU Stow) moved to the private
`lifetracker` repo, `stow/`, on 2026-11-06.

## New machine

Start with [docs/SSH-BOOTSTRAP-NOTES.md](docs/SSH-BOOTSTRAP-NOTES.md): it picks the page for the machine's
class (trusted Mac, trusted VM, cloud dev, edge), which makes it reachable from a trusted machine (SSH key,
Tailscale) and gets it a `lifetracker` checkout. The full setup guides live in the private `lifetracker`
repo (`guides/`).

## Layout

- `scripts/`: bootstrap scripts (`authorize-ss-key.sh`, `setup-tailscale.sh`, SSH key/config pulls). The
  macOS Brewfile is in `lifetracker` (`scripts/macinstall/`).
- `docs/`: the bootstrap pages, one per machine class.

## Contributing to this repo

After cloning, run:

```bash
./setup-hooks.sh
```

This installs a [gitleaks](https://github.com/gitleaks/gitleaks) pre-commit hook that blocks commits
containing secrets.
