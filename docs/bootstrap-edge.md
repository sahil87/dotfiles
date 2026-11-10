# Edge (service) VM

A VM that runs one service (media server, file sync, …) and holds only what that service needs. Its
services are exposed, so assume it **may be compromised**.

| Gets | Never gets |
|---|---|
| The `edge` age key, plus a per-machine key if its service has secrets of its own | The `trusted`, `dev` or `dev-cloud` keys |
| A **read-only** deploy key for `lifetracker`, if it `git pull`s its service config | A GitHub login, personal API tokens |
| Tailscale's SSH server, so personal dev VMs reach it without keys | Your personal SSH keys, the ss private key |

Over Tailscale it reaches the NAS (SMB) and whatever its service needs, one grant per need. Trusted machines
and personal dev VMs (over Tailscale SSH) reach it.

## On the VM

1. **Let the ss key in.** Proxmox VMs from the cloud-init template already have it. Anything else: log in
   once through the provider's console, then:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
   ```

2. **Join Tailscale as `tag:edge`:**
   ```bash
   sudo apt update && sudo apt install -y git curl
   git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
   ~/code/bootstrap/dotfiles/scripts/setup-tailscale.sh --edge
   ```
   Open the login URL, sign in as yourself, and approve the device in the admin console. `--edge` also
   turns on Tailscale's SSH server (`tailscale set --ssh`).

## From a trusted machine

`ssh <host>` must work first (step 1). Then, in `lifetracker`:

```bash
secrets/provision.sh edge <host> --deploy-key               # edge key + read-only lifetracker checkout
secrets/provision.sh edge <host> --key <name> --deploy-key  # plus its own key, if it has one
```

Leave off `--deploy-key` if the VM doesn't pull from `lifetracker`. The script refuses unless the host is
tagged `tag:edge`.

## Then

The service: `lifetracker/guides/setup_3edge/proxmox-vm.md` and the service's own
`lifetracker/services/<VMID>-<name>/README.md`.
