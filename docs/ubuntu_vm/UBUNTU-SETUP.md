
# Ubuntu OS Setup

* Install Ubuntu 24 ARM
* Install XFCE
* `./install.sh zsh ssh git`

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install xubuntu-desktop -y
# When it asks to choose display manager - choose lightdm
```

## On Cloning a VM

```bash
sudo hostnamectl set-hostname new-hostname

# Stop tailscale
sudo tailscale down

# Delete state AND cache
sudo rm /var/lib/tailscale/tailscaled.state
sudo rm -rf /var/cache/tailscale

# Restart the daemon to pick up the cleared state
sudo systemctl restart tailscaled

# Re-authenticate (will prompt for login)
sudo tailscale up --force-reauth
```

## Setup 

### Setup Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### Setup Remote Access
* Download the arm64 .deb from : https://download.nomachine.com/download/?id=30&platform=linux&distro=arm
```bash
# wget https://download.nomachine.com/download/9.3/Arm/nomachine_9.3.7_1_arm64.deb
# sudo dpkg -i nomachine_9.3.7_1_arm64.deb
sudo dpkg -i nomachine_*.deb
```

### SSH Setup

```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
```

### Passwordless login setup

Run this on the user's terminal, to copy keys to the remote host
```bash
ssh-copy-id username@remote-host
```

### Dev Tools
```bash
# Essential packages
sudo apt install -y git curl wget build-essential stow zsh direnv

# GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
gh auth login

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install code -y

# Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts           # Install latest LTS version
nvm alias default 'lts/*'   # Set it as default
node --version              # Verify

# Docker
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER

# Claude Code CLI
npm install -g @anthropic-ai/claude-code
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
cd stow/linux
./stowhelper.sh git ssh zsh direnv # or --all

# Switch default shell to zsh:
chsh -s $(which zsh)
```
Log out and back in for the change to take effect.

## 6. Verify SSH setup

```bash
#Verify:
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
