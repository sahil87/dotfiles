# SSH Key Bootstrap

New machines need SSH keys but can't pull them without authentication — a catch-22. We solve this using **Tailscale SSH** as a bootstrap mechanism:

1. **Install Tailscale** → authenticate via browser/OAuth (no SSH keys needed)
2. **Tailscale SSH** → authenticates connections using your Tailscale identity instead of SSH keys
3. **Pull SSH keys** → now you have them for GitHub, etc.

## Scripts

```bash
./scripts/setup-tailscale.sh       # Install and connect to tailnet
./scripts/clone-sshkeys-all.sh     # Pull all keys (sahil-weaver, sahil87, ss)
./scripts/clone-sshkeys-edge.sh    # Pull edge keys only (sahil-weaver, sahil87)
./scripts/authorize-ss-key.sh      # Add ss public key to local authorized_keys
```

- **all** vs **edge**: Use `clone-sshkeys-all.sh` on primary machines that need every key. Use `clone-sshkeys-edge.sh` on edge/secondary machines that only need GitHub keys.
- **authorize-ss-key**: Fetches `id_ed25519_ss.pub` from the Mac Mini and appends it to `~/.ssh/authorized_keys`, allowing the ss key to SSH into the current machine. The key itself doesn't need to be present locally.

## Prerequisites (on the source machine)

The machine storing your SSH keys (Mac Mini) needs Tailscale SSH enabled:

```bash
tailscale set --ssh
```

And your tailnet's [Access Controls](https://login.tailscale.com/admin/acls) need an SSH policy (the default policy already allows this).
