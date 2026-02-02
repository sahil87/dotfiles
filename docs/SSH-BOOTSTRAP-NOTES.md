# SSH Key Bootstrap

New machines need SSH keys but can't pull them without authentication — a catch-22. We solve this using **Tailscale SSH** as a bootstrap mechanism:

1. **Install Tailscale** → authenticate via browser/OAuth (no SSH keys needed)
2. **Tailscale SSH** → authenticates connections using your Tailscale identity instead of SSH keys
3. **Pull SSH keys** → now you have them for GitHub, etc.

```bash
./scripts/setup-tailscale.sh   # Install and connect to tailnet
./scripts/pull-ssh-keys.sh     # Pull keys from a remote VM via Tailscale SSH
```

## Prerequisites (on the source machine)

The machine storing your SSH keys (Mac Mini) needs Tailscale SSH enabled:

```bash
tailscale set --ssh
```

And your tailnet's [Access Controls](https://login.tailscale.com/admin/acls) need an SSH policy (the default policy already allows this).
