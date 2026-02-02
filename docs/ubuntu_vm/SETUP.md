
# Ubuntu OS Setup

* Install Ubuntu 24 ARM
* Install XFCE
* `./install.sh zsh ssh git`

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install xubuntu-desktop -y
# When it asks to choose display manager - choose lightdm
```

### Dev Tools
```bash
# Essential packages
sudo apt install -y git curl wget build-essential

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install code -y

# Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Then: nvm install --lts

# Docker
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER

# Claude Code CLI
npm install -g @anthropic-ai/claude-code
```

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

### Performance

```bash
# Disable animations for better remote performance (XFCE)
xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

### SSH Setup

```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
```

### Passwordless login setup

```bash
ssh-copy-id username@remote-host
```

## On Cloning a VM

```bash
sudo hostnamectl set-hostname new-hostname

sudo tailscale down
sudo rm -rf /var/lib/tailscale/tailscaled.state
sudo tailscale up
```
