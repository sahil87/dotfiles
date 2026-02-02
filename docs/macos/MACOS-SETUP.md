# macOS Setup

Steps for setting up a fresh macOS machine.

## 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Install essential tools

```bash
brew install git stow
xcode-select --install # Install's apple's git. But Homebrew's git would come earlier in path
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
./scripts/setup-tailscale.sh
./scripts/pull-ssh-keys.sh
```

The script will:
- Install Tailscale if not present
- Prompt you to authenticate Tailscale
- Pull keys from remote server

## 5. Install dotfiles with stow

```bash
cd stow/macos
./stowhelper.sh git ssh zsh # or --all
```

## 6. Verify SSH setup

```bash
ssh -T git@github.com          # Personal GitHub
ssh -T git@github.com-work     # Work GitHub
```

## 7. Clone additional repositories

```bash
cd ~/code/bootstrap
git clone git@github.com:sahil87/lifetracker.git
git clone git@github.com:sahil87/blog2020.git
git clone git@github.com:sahil-weaver/prompt-pantry.git
git clone git@github.com:wvrdz/dev-shell.git
```

## 8. Install Software Packages

```bash
cd $DOTFILES_DIR/scripts/macinstall
./macinstall.sh install
```

## 9. Install Zap (Zsh Plugin Manager)

```bash
ls "${XDG_DATA_HOME:-$HOME/.local/share}/zap" # Check if zap is already installed
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
```

## 10. Install additional dotfiles with stow

```bash
cd $LIFETRACKER_DIR/stow/macos
./stowhelper.sh graphite npm
```

## Notes (optional)

### Enable SSH Agent via 1Password

1Password Settings → Developer → Enable SSH Agent

```bash
mkdir -p ~/.1password ~/.ssh
ln -sf ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```

### Remote Desktop Setup

For Screen 5: https://help.edovia.com/en/screens-connect-5/getting-started/installing-mac

For Jump Desktop: turn all toggles on under Settings > Energy

### Nvm

```bash
nvm install --lts           # Install latest LTS version
nvm alias default 'lts/*'   # Set it as default
node --version              # Verify
```
