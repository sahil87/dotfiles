# macOS Setup

Steps for setting up a fresh macOS machine.

## 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Install essential tools

```bash
brew install git stow
```

## 3. Clone dotfiles

```bash
mkdir -p ~/code/bootstrap
git clone https://github.com/sahil87/dotfiles.git ~/code/bootstrap/dotfiles
cd ~/code/bootstrap/dotfiles
```

## 4. Bootstrap SSH keys via Tailscale

This pulls your private keys from a remote server over Tailscale.

```bash
./scripts/bootstrap-ssh-keys.sh
```

The script will:
- Install Tailscale if not present
- Prompt you to authenticate Tailscale
- Pull keys from remote server

## 5. Install dotfiles with stow

```bash
cd stow/macos
./dotinstall.sh --all
```

Or install specific packages:

```bash
./dotinstall.sh git ssh zsh
```

## 6. Verify SSH setup

```bash
ssh -T git@github.com          # Personal GitHub
ssh -T git@github.com-work     # Work GitHub
```
