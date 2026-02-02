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

Each subdirectory is a "stow package" that mirrors your home directory structure:

```
dotfiles/
├── git/
│   └── .gitconfig          → ~/.gitconfig
├── ssh/
│   └── .ssh/
│       └── config          → ~/.ssh/config
├── claude/
│   └── .claude/
│       ├── CLAUDE.md       → ~/.claude/CLAUDE.md
│       └── ...
```

## Usage

### Install/Link Configurations

From the `dotfiles` directory:

```bash
# Link a single program
stow -t ~ git

# Link multiple programs
stow -t ~ git ssh claude

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

- **aws** - AWS CLI configuration
- **byobu** - Terminal multiplexer config
- **claude** - Claude Code configuration
- **code-server** - VS Code server settings
- **ghostty** - Ghostty terminal config
- **git** - Git global configuration
- **jj** - Jujutsu VCS config
- **kube** - Kubernetes config (local copy)
- **npm** - NPM configuration
- **samba** - SMB client config
- **ssh** - SSH client configuration

## Notes

- **kube**: The original script linked to a Dropbox path for kubectl config. This local copy exists but you may want to continue using Dropbox for cross-machine sync.
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
