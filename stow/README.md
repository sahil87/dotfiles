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
├── packages/
│   ├── git/
│   │   └── .gitconfig       → ~/.gitconfig
│   ├── ssh_macos/
│   │   └── .ssh/
│   │       └── config       → ~/.ssh/config
│   ├── tu/
│   │   └── .config/tu/
│   │       └── tu.conf      → ~/.config/tu/tu.conf
│   ├── zsh/
│   │   └── ...
│   └── stowhelper.sh
└── archive/                 ← retired configs, not stowed
```

OS-specific packages are suffixed (`ssh_macos`, `ssh_linux`). Stow only the ones for the current host.

## Usage

### Helper script (preferred)

From `stow/packages/`:

```bash
./stowhelper.sh git zsh ssh_macos     # Install specific packages
./stowhelper.sh --backup zsh          # Back up conflicting real files, then install
./stowhelper.sh --adopt git           # Move existing ~/.gitconfig into the repo, then install
./stowhelper.sh --uninstall git       # Remove symlinks
./stowhelper.sh --list                # Show available packages
```

The helper always passes `--no-folding`, so stow links individual files rather than
whole directories. Without it, a missing `~/.config/tu` (for example) would become a
symlink into this repo and anything the tool writes next to its config would land in git.

`--all` installs every package, including both `ssh_*` variants (which conflict) and
`ghostty` (macOS only). Prefer naming packages explicitly.

### Raw stow

```bash
# Link a single program
stow -t ~ --no-folding git

# Link multiple programs
stow -t ~ --no-folding git ssh_macos zsh

# Unlink
stow -t ~ -D git

# Dry run: see what stow would do without making changes
stow -t ~ -n -v git
```

**Important:** Always use `-t ~` to target your home directory. Without it, stow links
into the parent directory (`stow/`), not your home.

### Existing files

Stow refuses to overwrite a real file that already exists in your home directory
(e.g. `~/.gitconfig`). Either:

1. **Back up and remove** it first (`./stowhelper.sh --backup <pkg>` does this with a timestamp suffix), or
2. **Adopt** it: `stow -t ~ --adopt git` moves the home copy into the package and links it.

**Warning:** `--adopt` overwrites the repo copy with whatever is currently in your home
directory. Check `git diff` afterwards and revert if the home copy was stale.

## Available Packages

Shared (both OSes):
- **git** - Git global config, aliases, and work/personal `includeIf` splits
- **zsh** - Zsh config (`.zshrc`, `.zshenv`, aliases, p10k). OS-specific bits live in `.zshrc_os_<os>.sh` and `.zshrc_aliases_<os>.sh` (sourced conditionally).
- **tu** - Token-usage tracker config (`~/.config/tu/tu.conf`)
- **hop** - Repo locator config (`~/.config/hop/hop.yaml`)
- **fab-kit** - fab-kit config (`~/.fab-kit/config.yaml`)

OS-specific:
- **ghostty** - Ghostty terminal config (macOS only)
- **ssh_macos** / **ssh_linux** - SSH client config. Split because the macOS host is a work machine (clients with `ControlMaster`, Tailscale hosts) and Linux hosts are leaf nodes. Stow only one per machine.

## Notes

- Edits made through the symlinks (e.g. `gh auth setup-git` writing to `~/.gitconfig`) land
  directly in the repo. Keep them OS-neutral: this is a shared package, so use `gh` from
  `PATH` rather than an absolute Homebrew/Linuxbrew path.
- `stow/archive/` holds retired configs (old byobu setup). Nothing in it is a stow package.
