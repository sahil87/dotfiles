# Dotfiles Management with GNU Stow

This directory contains configuration files managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

Install GNU Stow:

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow

# Arch
sudo pacman -S stow
```

## Structure

Packages live under `stow/packages/`. Each subdirectory there is a "stow package" that mirrors your home directory structure:

```
stow/
├── packages/                ← canonical home for stow packages
│   ├── git/
│   │   └── .gitconfig       → ~/.gitconfig
│   ├── ssh_macos/
│   │   └── .ssh/
│   │       └── config       → ~/.ssh/config
│   ├── zsh/
│   │   └── ...
│   └── stowhelper.sh
├── linux/                   ← legacy, retained for unlinked machines
├── macos/                   ← legacy, retained for unlinked machines
└── archive/
```

OS-specific packages are suffixed (`ssh_macos`, `ssh_linux`). Stow only the ones for the current host.

## Usage

### Install/Link Configurations

From `stow/packages/`:

```bash
# Link a single program
stow -t ~ git

# Link multiple programs
stow -t ~ git ssh_macos zsh

# Link everything (careful!)
stow -t ~ */
```

**Important:** Always use `-t ~` to target your home directory! Without it, stow will create symlinks in the parent directory (`lifetracker`), not your home.

**⚠️ Important**: If you already have dotfiles in your home directory (e.g., `~/.gitconfig`), stow will refuse to overwrite them. You have two options:

1. **Manual backup and remove**: Back up and delete existing files first
2. **Use --adopt**: Move existing files into the stow directory (see below)

### Unlink Configurations

```bash
# Unlink a program
stow -t ~ -D git

# Unlink multiple
stow -t ~ -D git ssh
```

### Adopt Existing Files (First-Time Setup)

If you have existing dotfiles you want to bring into stow management:

```bash
# Using stow directly
stow -t ~ --adopt git       # Moves ~/.gitconfig into dotfiles/git/.gitconfig

# Using the helper script
./dotinstall.sh --adopt git ssh
```

**Warning**: `--adopt` will **overwrite** the files in your dotfiles directory with whatever is currently in your home directory. If you've made changes to files in the dotfiles repo that you haven't deployed yet, they'll be lost. Consider backing up first.

### Dry Run (Preview Changes)

```bash
# See what stow would do without making changes
stow -t ~ -n -v git
```

## Available Packages

Shared (both OSes):
- **git** - Git global configuration
- **tu** - tu config
- **zsh** - Zsh config (`.zshrc`, `.zshenv`, aliases, p10k). OS-specific bits live in `.zshrc_os_<os>.sh` and `.zshrc_aliases_<os>.sh` (sourced conditionally).

OS-specific:
- **ghostty** - Ghostty terminal config (macOS only)
- **ssh_macos** / **ssh_linux** - SSH client config. Split because the macOS host is a work machine (clients with `ControlMaster`, Tailscale hosts) and Linux hosts are leaf nodes. Stow only one per machine.

## Layout notes

`stow/packages/` is the canonical home for packages. The `linux/` and `macos/` directories still contain duplicates from before the consolidation — they remain so existing symlinks on already-linked machines don't break. Migrate a machine by unstowing from `stow/linux/` or `stow/macos/` and re-stowing from `stow/packages/`. Once no machine depends on a legacy directory, delete it.

## Notes

- **cloudflare-ddns**: Not integrated with stow (was not in original script).
- **Conflicts**: Stow will refuse to overwrite existing files. Use `--adopt` to pull existing files in, or manually backup and remove them first.

## Migration from linkfiles_ubuntu.sh

The old script has been replaced by stow. Key improvements:

1. **Modularity**: Install configs per-program instead of all-at-once
2. **Safety**: Stow won't overwrite existing files without explicit flags
3. **Reversibility**: Easy to unlink with `stow -D`
4. **Standard tool**: No custom bash to maintain

Old workflow:
```bash
./linkfiles_ubuntu.sh  # Everything at once
```

New workflow:
```bash
stow git ssh claude    # Just what you need
```
