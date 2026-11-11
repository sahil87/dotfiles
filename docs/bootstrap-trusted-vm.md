# Trusted VM

A VM on your own Proxmox host, mainly for agent orchestration. It is **trusted**: it holds what
your Macs hold (the ss key, every age key), so it reaches and can run everything. Agents running here are
inside the trusted boundary, and that's an accepted risk (`lifetracker/guides/access-model.md`, *Agents on
trusted machines*). Run code you don't trust on a dev VM instead.

| Gets | Never gets |
|---|---|
| The ss key and every age key, copied from a trusted machine | Copies of your personal GitHub keys (`sahil87`, `sahil-noon`): it gets its own |
| Its own GitHub SSH key and `gh` login (personal account) | Password SSH logins |
| A `lifetracker` checkout through that login | A service listening on the LAN without auth: edge VMs share the LAN |

## On the VM

1. **Create it** from Proxmox template **9026** (ss key only, password login refused):
   `lifetracker/guides/setup_3edge/proxmox-vm.md`, step 1. Then:
   ```bash
   sudo apt update && sudo apt install -y git curl
   ```

2. **Join Tailscale as `tag:trusted`:**
   ```bash
   git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
   ~/code/bootstrap/dotfiles/scripts/setup-tailscale.sh --trusted
   ```
   Open the login URL, sign in as yourself, and approve the device in the admin console. It joins tagged,
   not as you.

3. **GitHub**: the VM's own key, revocable on its own. Install `gh`
   ([Linux install](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)), then:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "$(hostname)"
   gh auth login   # choose SSH, upload ~/.ssh/id_ed25519_github.pub
   ```

4. **Clone lifetracker:**
   ```bash
   ~/code/bootstrap/dotfiles/scripts/clone-sshconfig-init.sh   # starter ~/.ssh/config, enough to clone
   gh api meta --jq '.ssh_keys[]' | sed 's/^/github.com /' >> ~/.ssh/known_hosts   # GitHub's host keys, over HTTPS
   git clone git@github.com:sahil87/lifetracker.git ~/code/bootstrap/lifetracker
   ```

## From a trusted machine

`ssh <host>` must work first (the ss key, from cloud-init). Check the host key fingerprint against the VM's
console before accepting it; on Proxmox the guest agent is that console:
`qm guest exec <VMID> -- ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` on the host. Confirm the tag,
then copy the keys:

```bash
ssh <host> 'tailscale status --self --peers=false --json' | grep -o '"tag:trusted"'   # must print it
ssh <host> 'mkdir -p ~/.config/sops/age ~/.ssh && chmod 700 ~/.config/sops ~/.config/sops/age ~/.ssh'
scp -p ~/.config/sops/age/*.txt <host>:.config/sops/age/
scp -p ~/.ssh/id_ed25519_ss ~/.ssh/id_ed25519_ss.pub <host>:.ssh/
ssh <host> 'chmod 600 ~/.config/sops/age/*.txt ~/.ssh/id_ed25519_ss'
```

Then, from the lifetracker checkout on the trusted machine (scripts and sizing:
`lifetracker/guides/access-model.md` → *Trusted VMs*):

```bash
ssh <host> 'DATA_DISK=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1 DOCKER_SIZE=60G bash -s' \
  < scripts/gcp/dev-vm-bootstrap.sh                                   # data disk: /home, docker, /tmp, swap
ssh <host> 'bash -s' < scripts/linux/trusted-vm-firewall.sh            # over Tailscale: closes the LAN
ssh <host> 'bash -s' < scripts/linux/desktop-xfce-xrdp.sh              # optional: XFCE + xrdp
```

## Then

Continue with `lifetracker/guides/setup_2dev/ubuntu-common.md` from step 5 (Zap, stow, Homebrew, tools).
Once Homebrew is in, install the gitleaks hook in both repos this VM can push to:

```bash
brew install pre-commit
(cd ~/code/bootstrap/lifetracker && ./setup-hooks.sh)
(cd ~/code/bootstrap/dotfiles && ./setup-hooks.sh)
```

A HexoKit runner here listens on `localhost` only and is published with `tailscale serve` as
`svc:<ssh alias>`. Trusted devices reach it; never grant it to a lower class.
