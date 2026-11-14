# Machine bootstrap

This public repo holds the minimum needed to reach a new machine and give it a checkout of private
`lifetracker`. Stop at the checkout: credentials beyond those needed to clone, disk setup, firewall,
dotfiles, tools and services belong in `lifetracker/guides/`.

## Pick the machine's class

| Class | Machines | Tailscale setup | Continue after checkout |
|---|---|---|---|
| Trusted Mac | Laptop, Mac mini | As you (untagged); mini uses `--trusted` | `guides/setup_1trusted/macbook.md` (mini: then `macmini.md`) |
| Trusted VM | VMs on your own Proxmox hosts | `--trusted` | `guides/setup_1trusted/ubuntu-trusted.md` |
| Dev VM | Org cloud, where others have root | `--dev` | `guides/setup_2dev/gcp.md` or `ubuntu-common.md` |
| Edge VM | Service VMs | `--edge` | `guides/setup_3edge/ubuntu-edge.md` and the service README |

Choose the class before starting. Non-trusted machines never receive the ss private key, trusted age
keys or personal GitHub credentials, and never use SSH agent forwarding. Keys are pushed from a trusted
machine. The full rules are in `lifetracker/guides/access-model.md`.

Proxmox hosts and the NAS are set up from an existing trusted machine using `lifetracker` only
(`guides/setup_4infra/`, `guides/setup_5nas/`). VM creation also happens there: Proxmox template **9026**
(`services/cloudinit-notes.md`), or the cloud provider's VM creation flow. Start below on the new machine.

## 1. Initial access and packages

**Linux VM:** log in through its console/provider first. Proxmox template 9026 already authorizes the ss
public key and refuses password SSH logins. For other VMs, authorize that public key:

```bash
sudo apt update && sudo apt install -y git curl openssh-client openssh-server
# Skip this line on template 9026 clones:
curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
```

On GCP, first use `gcloud compute ssh <vm> --tunnel-through-iap --strict-host-key-checking=yes` (plus your
project and zone). Run setup as the user you'll work as. The private GCP guide's bootstrap script can
prepare that user and the data disk from an existing trusted machine before these steps.

**Mac:** install Git/Apple Command Line Tools if needed (`xcode-select --install`).

## 2. Join Tailscale

```bash
mkdir -p ~/code/bootstrap
git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
cd ~/code/bootstrap/dotfiles
# Run ONE, matching the table above:
./scripts/setup-tailscale.sh --trusted   # trusted VM or Mac mini
# ./scripts/setup-tailscale.sh --dev     # dev VM
# ./scripts/setup-tailscale.sh --edge    # edge VM
# ./scripts/setup-tailscale.sh           # trusted laptop only
```

Open the login URL, sign in as yourself and approve the device in the admin console. Linux VMs always
join tagged; a plain `tailscale up` would join as you, a trusted identity.

## 3. Verify incoming SSH (VMs)

From an existing trusted machine, verify the new VM's SSH host fingerprint through the console/provider
before accepting its Tailscale host key. Read the fingerprint on the VM through that verified channel:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

For Proxmox, run `qm guest exec <VMID> -- ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` on the host.
For GCP, run the fingerprint command through `gcloud compute ssh … --strict-host-key-checking=yes`.
Compare with the fingerprint presented over Tailscale and confirm it before accepting. Use the VM's
Tailscale hostname/IP as `<host>` below; a private SSH alias isn't required yet.

Check from the trusted machine that `ssh <host> 'whoami; hostname'` works as the intended user.

## 4. Get the lifetracker checkout

### Trusted Mac or trusted VM

On the new machine, install GitHub CLI (`brew install gh` on a Mac;
[official Linux instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) on a VM).
Generate a fresh personal-account key on this machine; don't overwrite an existing key:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Mac:
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sahil87 -C "sahil87@$(hostname)"
# Trusted VM: use this instead of the Mac command:
# ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "sahil87@$(hostname)"
gh auth login --hostname github.com --git-protocol ssh --web
```

Approve in the browser as **sahil87** and select the matching new `.pub` when asked to upload a key.
Each machine has its own GitHub key, so it can be revoked independently.

```bash
~/code/bootstrap/dotfiles/scripts/clone-sshconfig-init.sh
# GitHub host keys obtained over HTTPS:
gh api meta --jq '.ssh_keys[]' | sed 's/^/github.com /' >> ~/.ssh/known_hosts
git clone git@github.com:sahil87/lifetracker.git ~/code/bootstrap/lifetracker
```

The starter SSH config supports both key filenames. If a config already exists, review it before
replacing it. No ss private key, age keys or work-account login are needed for this clone.

### Dev or edge VM

Run this **from an existing trusted machine**, in its `lifetracker` checkout. Its active `gh` account must
have admin permission on `sahil87/lifetracker` to register a deploy key.

```bash
cd ~/code/bootstrap/lifetracker
# Choose ONE:
secrets/provision.sh dev <host>
# secrets/provision.sh edge <host> --deploy-key
```

The script checks `tag:dev` / `tag:edge`, makes the VM generate its own deploy key, registers it as
**read-only**, and creates `~/code/bootstrap/lifetracker` configured to use it for future pulls. Dev also
receives the `dev` age key as part of this existing provisioner; edge receives no age key in this step.
No GitHub CLI login is needed on either VM to obtain the checkout. Never copy a trusted machine's
private SSH keys to dev or edge.

## 5. Continue in lifetracker

The new machine now has `~/code/bootstrap/lifetracker`. Open the class guide from the table at the top;
skip initial-access/checkout steps already completed here. All remaining setup lives there.
