# Personal dev VM

A VM on your own hardware (Proxmox, Parallels) that you work in across many repos. Agents run here with
permissions skipped, so assume it **may be compromised**: it can't reach trusted machines, and it holds
nothing that opens one.

| Gets | Never gets |
|---|---|
| The `dev` age key, pushed from a trusted machine | The `trusted`, `edge` or `dev-cloud` keys |
| Its own GitHub SSH key and `gh` login (personal account) | Your personal SSH keys, the ss private key |
| A `lifetracker` checkout through that login | A forwarded SSH agent |

Over Tailscale it reaches other personal dev VMs, and edge VMs over Tailscale SSH (no keys on this VM).

Its `gh` login can push to `dotfiles` and `lifetracker`, which trusted machines run code from. That is
accepted for personal dev VMs you operate yourself (`lifetracker/guides/access-model.md`, rule 3).

## On the VM

1. **Packages:**
   ```bash
   sudo apt update && sudo apt install -y git curl
   ```

2. **Let the ss key in.** Proxmox VMs from the cloud-init template already have it. Anything else:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
   ```

3. **Join Tailscale as `tag:dev`:**
   ```bash
   git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
   ~/code/bootstrap/dotfiles/scripts/setup-tailscale.sh --dev
   ```
   Open the login URL, sign in as yourself, and approve the device in the admin console. It joins tagged,
   not as you.

4. **GitHub**: the VM's own key, revocable on its own. Install `gh`
   ([Linux install](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)), then:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "$(hostname)"
   gh auth login   # choose SSH, upload ~/.ssh/id_ed25519_github.pub
   ```

5. **Clone lifetracker:**
   ```bash
   ~/code/bootstrap/dotfiles/scripts/clone-sshconfig-init.sh   # starter ~/.ssh/config, enough to clone
   git clone git@github.com:sahil87/lifetracker.git ~/code/bootstrap/lifetracker
   ```

## From a trusted machine

`ssh <host>` must work first (the ss key, step 2). Check the host key fingerprint against the VM's console
before accepting it. Then, in `lifetracker`:

```bash
secrets/provision.sh dev <host>   # the dev age key, nothing else; refuses unless <host> is tag:dev
```

## Then

Continue with `lifetracker/guides/setup_2dev/ubuntu-common.md` from step 5 (Zap, stow, Homebrew, tools).
Once Homebrew is in, install the gitleaks hook in both repos this VM can push to:

```bash
brew install pre-commit
(cd ~/code/bootstrap/lifetracker && ./setup-hooks.sh)
(cd ~/code/bootstrap/dotfiles && ./setup-hooks.sh)
```
