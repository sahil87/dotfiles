# Machine Access Bootstrap

This repo is public, so it holds only what a new machine needs to become **reachable from a trusted
machine** (laptop, Mac mini). Everything after that (age keys, GitHub deploy keys, secrets) is done
from the private `lifetracker` repo.

Two kinds of machine:
- **Trusted**: the Macs. Join Tailscale as your user and hold every key.
- **Edge**: Linux VMs and dev workstations. Join Tailscale as `tag:edge`, can't reach trusted
  machines, and never get copies of your personal SSH keys.

## Edge machines

1. **Let the ss key in.** Trusted machines SSH in with the ss key.
   - Proxmox VMs: cloud-init installs it; nothing to do.
   - Anything else (e.g. GCP): log in once through the provider's console, then run on the machine:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
     ```
2. **Join Tailscale as edge** (on the machine, from a clone of this repo):
   ```bash
   git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
   ~/code/bootstrap/dotfiles/scripts/setup-tailscale.sh --edge
   ```
   Open the login URL, sign in as yourself, and approve the device in the admin console. The
   device joins tagged, not as you.
3. **From a trusted machine**: run `secrets/provision-edge.sh <host>` in `lifetracker` (age key;
   add `--deploy-key` for service VMs that `git pull`).
4. **Dev workstations only, GitHub access**: give the machine its own key, revocable on its own:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "$(hostname)"
   gh auth login   # choose SSH, upload ~/.ssh/id_ed25519_github.pub
   ```
   The `ssh_linux` stow package uses `~/.ssh/id_ed25519_github` for `github.com`.

## Trusted machines

```bash
./scripts/setup-tailscale.sh       # Install and join the tailnet as your user
./scripts/clone-sshkeys-all.sh     # Pull SSH keys (sahil-noon, sahil87, ss) from the Mac mini
./scripts/clone-sshconfig-init.sh  # Copy a starter ~/.ssh/config (Linux layout)
```

The age keys for sops come from the Mac mini too; see `lifetracker/secrets/README.md`.

## After this

The rest of the setup (packages, stow, tools) is in the private `lifetracker` repo, under `guides/`:
`setup_1trusted/` for your Macs, `setup_2dev/` for VMs you work in, `setup_3edge/` for service VMs.
