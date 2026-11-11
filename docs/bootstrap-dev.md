# Dev VM

A dev VM in an org cloud project. Everyone with SSH rights on the project has root on it, so treat
everything on the VM as **visible to the org**, and the machine as one an org admin can impersonate.

| Gets | Never gets |
|---|---|
| The `dev` age key only: secrets the org may see | The `trusted` key or any per-machine key (`stss`, …) |
| A **read-only** deploy key for `lifetracker` (its checkout holds the dotfiles) | Push access to `dotfiles` or `lifetracker` |
| Its own GitHub SSH key and `gh` login as the **work** account | Your personal SSH keys, the ss private key |
| Personal-account repos only through a fine-grained token with an expiry, never `dotfiles` or `lifetracker` | A forwarded SSH agent, ever: root here could use your keys while you're connected |

Over Tailscale it reaches **only** the runner services hosted on dev VMs. Trusted machines reach it;
nothing else does.

## Create it and log in through the provider

Log in once with the provider's own tool, with host key checking that goes through the provider's API
(GCP: `gcloud compute ssh <vm> --tunnel-through-iap --strict-host-key-checking=yes`). This login user has
sudo.

On GCP, `lifetracker/scripts/gcp/dev-vm-bootstrap.sh` does steps 1 and 2 below plus the data disk and the
user, run from a trusted machine through `gcloud`: see `lifetracker/guides/setup_2dev/gcp.md`. Then go
straight to step 3.

## On the VM

1. **Let the ss key in**, as the user you'll work as:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/sahil87/dotfiles/main/scripts/authorize-ss-key.sh | bash
   ```

2. **Get the bootstrap scripts:**
   ```bash
   sudo apt update && sudo apt install -y git curl
   git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
   ```

3. **Join Tailscale as `tag:dev`**, in an interactive session (the login URL only shows up reliably
   there):
   ```bash
   ~/code/bootstrap/dotfiles/scripts/setup-tailscale.sh --dev
   ```
   Open the URL, sign in as yourself, approve the device in the admin console.

4. **GitHub**, as the work account. Install `gh`
   ([Linux install](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)), then:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "$(hostname)"
   gh auth login   # the work account; choose SSH, upload ~/.ssh/id_ed25519_github.pub
   ```

## From a trusted machine

1. **Trust the host key** only through a verified channel: read the fingerprint through the provider
   (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` over the provider login above), compare it with what
   the VM presents over Tailscale (`ssh-keyscan`), and only then add it to `known_hosts`.

2. **Provision**, in `lifetracker`:
   ```bash
   secrets/provision.sh dev <host>
   ```
   It refuses unless the host is tagged `tag:dev`. Then it pushes the `dev` key and nothing else,
   registers a read-only deploy key for `lifetracker`, and clones it to `~/code/bootstrap/lifetracker` on the VM.

## Then

Continue with `lifetracker/guides/setup_2dev/gcp.md` step 6 (the common dev steps: Zap, stow, Homebrew,
tools), and its step 7 for a runner service.
