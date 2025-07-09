#!/bin/bash

log_info() {
  local msg="$1"
  echo -e "\n\e[1;33m[ =============================\e[0m \e[34m[*]\e[0m \e[1;32m${msg}\e[0m \e[1;33m============================= ]\e[0m\n"
}

log_info "Starting script"

sudo apt update -y && sudo apt upgrade -y

log_info "Installing updates"

# Install the necessary packages
sudo apt install -y tree nmap git nasm curl zsh vim python3 python3-pip python3-dev libreoffice nbd-client cupp php \
  libssl-dev libffi-dev build-essential libncurses-dev simplescreenrecorder proxychains libguestfs-tools dnsmap lolcat \
  ffmpeg open-vm-tools open-vm-tools-desktop gem gcc ruby-dev gcc-multilib default-jdk fcrackzip ntfs-3g-dev sqlmap ffuf jq \
  apt-transport-https nodejs p7zip-full net-tools ncdu dnsenum snmp braa onesixtyone mysql-server cryptsetup ettercap-graphical \
  nfs-common whois wfuzz perl vnstat freerdp2-x11 smbmap smbclient hashcat locate upx qemu-utils dislocker ldap-utils \
  proxychains sshuttle pipx socat neofetch fping pkg-config elfutils patchelf xsel cmake qemu-user-static \
  gdb-multiarch qemu-user liblzma-dev musl-tools eza

# tmux
# git clone https://github.com/thewtex/tmux-mem-cpu-load ~/.tmux-mem-cpu-load
# cd ~/.tmux-mem-cpu-load
# cmake .
# make
# sudo make install
# Cleanup

sudo apt autoremove -y

log_info "Installing msfconsole"

# msfconsole install
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall

log_info "Installing Neovim"

# Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm -rf nvim-linux64.tar.gz

log_info "Installing seccomp tools"

# Seccomp tools
sudo gem install seccomp-tools one_gadget evil-winrm wpscan

log_info "Installing pwntools"

# pwntools
sudo apt update -y
python3 -m pip install --upgrade pip --break-system-packages
python3 -m pip install --upgrade pwntools flask termcolor ropper ropgadget checksec.py tqdm pypykatz fierce --break-system-packages

# Set tmux mouse
echo 'set -g mouse on' >> ~/.tmux.conf

log_info "Installing pwndbg"

# pwndbg
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
cd ../

log_info "Installing docker"

# Docker
sudo apt update -y
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

log_info "Installing MANASU"


sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
log_info "Installing MANASU 1"

sudo usermod -aG docker ${USER}
log_info "Installing MANASU 2"

# newgrp docker

log_info "Installing typora"

# Typora installation
# wget -qO - https://typoraio.cn/linux/public-key.asc | gpg --dearmor -o /usr/share/keyrings/typora-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/typora-archive-keyring.gpg] https://typora.io/linux ./" | sudo tee /etc/apt/sources.list.d/typora.list > /dev/null

# Install ghidra, crackmapexec, go, searchsploit, seclists
#snap install ghidra
#snap install crackmapexec
sudo snap install typora
sudo snap install go
sudo snap install searchsploit
sudo snap install seclists

log_info "Installing pwninit"

cargo install pwninit

log_info "Creating SSH keys"

# Create ssh key for github
ssh-keygen -t rsa -b 4096 -C "thanosx97x@gmail.com"
ssh-add ~/.ssh/id_rsa

# Add GitHub identity
git config --global user.email "thanosx97x@gmail.com"
git config --global user.name "w3th4nds"

# Clone the Impacket repository to /opt/impacket
# sudo git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket

# Install Impacket requirements
# sudo python3 -m pip install -r /opt/impacket/requirements.txt --break-system-packages

# Install Impacket
# cd /opt/impacket && sudo python3 setup.py install

log_info "Installing Oh My ZSH"

# Oh My Zsh installation
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Cleanup
sudo apt autoremove -y

# nvim .config
# mkdir -p ~/.config/nvim/ && cp -r ~/github/exploit-template/nvim_config/nvim/ ~/.config/ 

# Change fonts from nerd fonts - https://www.nerdfonts.com/font-downloads
# Geist - Hack are nice
# sudo mkdir -p /usr/share/fonts/nerd
# sudo mv *.ttf /usr/share/fonts/nerd && fc-cache -f -v

# Gobuster
# wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
# sudo tar -xvf go1.22.0.linux-amd64.tar.gz -C /usr/local
# echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
# source ~/.profile
# go install github.com/OJ/gobuster/v3@latest
# echo 'export PATH=$PATH:~/go/bin' >> ~/.profile
# source ~/.profile

# Inside ~/.zshrc
plugins=(git z sudo zsh-autosuggestions zsh-syntax-highlighting)

# Aliases for zsh
<<aliases
export PATH=$PATH:~/.local/bin
alias l='eza --icons'
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias plz='sudo'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias c_template='cp ~/github/exploit-template/challenge_folder/c_template.c .'
alias readme_template='cp ~/github/exploit-template/challenge_folder/readme.md ./README.md'
alias make_template='cp ~/github/exploit-template/challenge_folder/Makefile .'
alias pwn_template='cp ~/github/exploit-template/challenge_folder/solver.py . && echo "[+] solver.py created!"'
alias ghidra='~/Downloads/ghidra_9.2.2_PUBLIC/ghidraRun'
alias chall_template='~/github/exploit-template/challenge_folder/chall.sh && echo "[+] Directory created!"'
alias dockershell='docker run --rm -i -t --entrypoint=/bin/bash'
alias dockershellsh='docker run --rm -i -t --entrypoint=/bin/sh'
alias dockerrm='docker rm -f'
alias python='/usr/bin/python3'
alias checksec='/usr/bin/checksec --file '
alias binja='~/Downloads/binaryninja/binaryninja'
alias vim='/opt/nvim-linux64/bin/nvim'
alias zzz='poweroff'
alias john='~/github/john/run/john'
alias cme='crackmapexec'
alias smtp-user-enum='~/github/exploit-template/smtp-user-enum.pl'
alias xsstrike='python3 ~/github/XSStrike/xsstrike.py'
alias xxeinjector='ruby ~/github/exploit-template/XXEinjector.rb'
alias qemu='/usr/bin/qemu-aarch64'

pusher(){
  comment="$1"
  RED='\033[0;31m'
  RESET='\033[0m'
  if [ -z "$1" ]; then
    echo -e "${RED}[-] Comment missing!${RESET}"
  else
    git pull; \
    find . -name '.gdb_history' -exec rm -f {} \; && \
    find . -name 'nohup.out' -exec rm -f {} \; && \
    git add .; \
    git commit -m "$comment"; \
    git push 
  fi
}

function prod-push() {
   docker build -t registry.htbsvc.net/hackthebox/htb:$1 . && docker push registry.htbsvc.net/hackthebox/htb:$1
}

trans() {
  local level=$1

  if [[ "$level" -ge 0 && "$level" -le 10 ]]; then
    local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
    local percent=$((level * 10))
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-transparent-background true
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-transparency-percent $percent
    echo "Transparency set to $level/10 (${percent}%)"
  else
    echo "Usage: trans <0-10>"
  fi
}

# To make zsh default
# chsh -s $(which zsh)
