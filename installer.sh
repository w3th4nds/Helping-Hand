#!/bin/bash

set -e

log_info() {
  local msg="$1"
  echo -e "\n\e[1;33m[ =============================\e[0m \e[34m[*]\e[0m \e[1;32m${msg}\e[0m \e[1;33m============================= ]\e[0m\n"
}

# Install APT package if not installed
install_package() {
  local pkg="$1"
  if dpkg -s "$pkg" &> /dev/null; then
    log_info "$pkg already installed"
  else
    sudo apt install -y "$pkg"
  fi
}

# Install snap package if not installed
install_snap() {
  local snap_pkg="$1"
  if snap list | grep -q "^$snap_pkg"; then
    log_info "Snap package $snap_pkg already installed"
  else
    sudo snap install "$snap_pkg"
  fi
}

# Install Ruby gem if not installed
install_gem() {
  local gem_name="$1"
  if gem list -i "$gem_name" > /dev/null; then
    log_info "Gem $gem_name already installed"
  else
    sudo gem install "$gem_name"
  fi
}

# Install npm package if not installed
install_npm() {
  local pkg="$1"
  if npm list -g --depth=0 | grep -q "$pkg@"; then
    log_info "npm package $pkg already installed"
  else
    sudo npm install -g "$pkg"
  fi
}

# Install cargo crate if not installed
install_crate() {
  local crate="$1"
  if command -v "$crate" &> /dev/null; then
    log_info "Cargo crate $crate already installed"
  else
    cargo install "$crate"
  fi
}

install_com() {
  log_info "Installing common tools"
  sudo apt update -y && sudo apt upgrade -y

  local packages=(
    tree git curl zsh vim python3 python3-pip python3-dev libreoffice
    libssl-dev libffi-dev build-essential libncurses-dev libguestfs-tools tmux
    ffmpeg open-vm-tools open-vm-tools-desktop gem gcc ruby-dev gcc-multilib default-jdk
    fcrackzip ntfs-3g-dev jq nodejs npm p7zip-full net-tools ncdu
    nfs-common whois perl vnstat freerdp2-x11 hashcat locate upx
    pipx socat neofetch fping pkg-config elfutils xsel cmake liblzma-dev eza subversion
  )

  for pkg in "${packages[@]}"; do
    install_package "$pkg"
  done

  log_info "Installing Docker"
  if ! command -v docker &> /dev/null; then
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
  else
    log_info "Docker already installed"
  fi

  install_snap typora
  install_snap seclists

  log_info "Installing Oh My Zsh"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    chsh -s "$(which zsh)"
  else
    log_info "Oh My Zsh already present"
  fi

  log_info "Installing powerlevel10k"
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  else
    log_info "powerlevel10k already present"
  fi

  if ! command -v tmux-mem-cpu-load &> /dev/null; then
    log_info "Installing tmux-mem-cpu-load"
    TMPDIR=$(mktemp -d)
    git clone https://github.com/thewtex/tmux-mem-cpu-load "$TMPDIR"
    cd "$TMPDIR"
    cmake . && make && sudo make install
    cd - && rm -rf "$TMPDIR"
  else
    log_info "tmux-mem-cpu-load already installed"
  fi

  grep -q "set -g mouse on" ~/.tmux.conf 2>/dev/null || echo 'set -g mouse on' >> ~/.tmux.conf
  sudo apt autoremove -y
}

install_pwn() {
  log_info "Installing pwn tools"
  local pwn_pkgs=(nasm qemu-utils patchelf cmake qemu-user-static gdb-multiarch qemu-user musl-tools)
  for pkg in "${pwn_pkgs[@]}"; do
    install_package "$pkg"
  done

  for gem in seccomp-tools one_gadget evil-winrm wpscan; do
    install_gem "$gem"
  done

  log_info "Installing Python pwn tools"
  python3 -m pip install --upgrade pip --break-system-packages || true
  python3 -m pip install --upgrade pwntools flask termcolor ropper ropgadget checksec.py tqdm pypykatz fierce --break-system-packages || true

  if [ ! -d "./pwndbg" ]; then
    git clone https://github.com/pwndbg/pwndbg
    cd pwndbg && ./setup.sh && cd ..
  else
    log_info "pwndbg already exists"
  fi

  if ! command -v cargo &> /dev/null; then
    log_info "Installing Rust"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
  fi

  install_crate pwninit
}

install_web() {
  log_info "Installing web tools"
  local web_pkgs=(nmap nbd-client cupp php proxychains dnsmap lolcat sqlmap ffuf dnsenum snmp braa onesixtyone \
    mysql-server cryptsetup ettercap-graphical wfuzz smbmap smbclient dislocker ldap-utils sshuttle)
  for pkg in "${web_pkgs[@]}"; do
    install_package "$pkg"
  done

  if ! command -v msfconsole &> /dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod 755 msfinstall
    ./msfinstall
  else
    log_info "Metasploit already installed"
  fi

  install_snap searchsploit
}

install_dot() {
  log_info "Installing dotfiles"

  [ -f ~/.zshrc ] || wget -O ~/.zshrc https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/dotfiles/.zshrc
  [ -f ~/.tmux.conf ] || wget -O ~/.tmux.conf https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/dotfiles/.tmux.conf

  if [ ! -d /usr/share/fonts/nerd ]; then
    sudo mkdir -p /usr/share/fonts/nerd
    sudo svn export https://github.com/w3th4nds/Helping-Hand/trunk/dotfiles/nerd /usr/share/fonts/nerd
    sudo fc-cache -vf
  else
    log_info "Nerd fonts already installed"
  fi

  bash <(curl -sSL https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/nvim_install.sh)
}

install_all() {
  install_pwn
  install_web
  install_dot
}

# === Parse CLI arguments ===
run_pwn=false
run_web=false
run_dot=false
run_all=false

if [ "$#" -eq 0 ]; then
  echo -e "\nUsage: $0 [--all] [--pwn] [--web] [--dot] [--com]"
  exit 1
fi

while [[ "$1" != "" ]]; do
  case $1 in
    --all ) run_all=true ;;
    --pwn ) run_pwn=true ;;
    --web ) run_web=true ;;
    --dot ) run_dot=true ;;
    --com ) install_com; exit 0 ;;
    * ) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

install_com
$run_all && install_all
$run_pwn && install_pwn
$run_web && install_web
$run_dot && install_dot

log_info "Installation finished successfully"
