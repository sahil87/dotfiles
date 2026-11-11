# Machine bootstrap

This repo is public, so it holds only what a new machine runs to become **reachable from a trusted
machine** and to get a checkout of the private `lifetracker` repo. Everything after that (age keys,
GitHub deploy keys, the dotfiles in `stow/`, the full guides) is in `lifetracker`.

## Which page

| Class | Machines | Tailscale identity | Page |
|---|---|---|---|
| **Trusted** | Your Macs (laptop, Mac mini) | You (untagged); the mini `tag:trusted` | [below](#trusted-machines) |
| **Trusted** | VMs on your own Proxmox hosts (agent orchestration) | `tag:trusted` | [bootstrap-trusted-vm.md](bootstrap-trusted-vm.md) |
| **Dev** | Dev VMs in an org cloud project, where others have root | `tag:dev` | [bootstrap-dev.md](bootstrap-dev.md) |
| **Edge** | Service VMs | `tag:edge` | [bootstrap-edge.md](bootstrap-edge.md) |

Proxmox hosts and the NAS are set up from `lifetracker` only (`guides/setup_4infra/`, `guides/setup_5nas/`).

Access flows **down, never up**: trusted machines SSH into everything else with the ss key, and nothing
below holds a key or a network path that opens a machine above. What a lower machine can read is decided
by the age keys a trusted machine pushes to it, so every class can have a `lifetracker` checkout. The model
in full: `lifetracker/guides/access-model.md`.

Rules for every machine that isn't trusted:
- Join Tailscale **tagged** (`setup-tailscale.sh --dev | --edge`). A plain `tailscale up`
  joins it as you, a trusted device.
- It never gets your personal SSH keys (`id_ed25519_sahil87`, `id_ed25519_sahil-noon`, `id_ed25519_ss`).
- Never forward your SSH agent to it.
- Keys arrive **pushed** from a trusted machine; the machine never fetches them itself.

## Trusted machines

```bash
git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
cd ~/code/bootstrap/dotfiles
./scripts/setup-tailscale.sh       # install and join the tailnet as your user
./scripts/clone-sshkeys-all.sh     # pull the ss key from the Mac mini
for a in sahil87 sahil-noon; do ssh-keygen -t ed25519 -N "" -C "$a@$(hostname -s)-$(date +%F)" -f ~/.ssh/id_ed25519_$a; done
# add each .pub to its own GitHub account (Settings → SSH keys), titled after this machine
./scripts/clone-sshconfig-init.sh  # starter ~/.ssh/config (github.com only), enough to clone lifetracker
git clone git@github.com:sahil87/lifetracker.git ~/code/bootstrap/lifetracker
```

`clone-sshkeys-all.sh` pulls from the Mac mini by its Tailscale name; `KEY_SOURCE=<host>` pulls from
another trusted machine. GitHub keys are one per machine per account (GitHub refuses one key on two
accounts), so removing one machine's keys cuts off only that machine. Then follow `lifetracker/guides/setup_1trusted/` (apps from the Brewfile, stow,
age keys).
