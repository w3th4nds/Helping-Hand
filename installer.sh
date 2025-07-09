#!/bin/bash

set -e

log_info() {
  local msg="$1"
  echo -e "\n\e[1;33m[ =============================\e[0m \e[34m[*]\e[0m \e[1;32m${msg}\e[0m \e[1;33m============================= ]\e[0m\n"
}

usage() {
  echo -e "\nUsage: $0 [--all] [--pwn] [--web] [--dot] [--com]\n"
  echo "  --all    Install everything."
  echo "  --pwn    Install binary exploitation tools."
  echo "  --web    Install web exploitation tools."
  echo "  --dot    Install dot and configuration files."
  echo "  --com    Install common tools only. (This runs by default)"
  exit 1
}

install_com() {
  log_info "Installing common tools"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y tree git curl zsh vim python3 python3-pip python3-dev libreoffice \
    libssl-dev libffi-dev build-essential libncurses-dev libguestfs-tools tmux \
    ffmpeg open-vm-tools open-vm-tools-desktop gem gcc ruby-dev gcc-multilib default-jdk \
    fcrackzip ntfs-3g-dev jq nodejs p7zip-full net-tools ncdu \
    nfs-common whois perl vnstat freerdp2-x11 hashcat locate upx \
    pipx socat neofetch fping pkg-config elfutils xsel cmake liblzma-dev eza subversion

  # Snap install fallback
  if ! command -v snap &>/dev/null; then
    log_info "Installing snapd"
    sudo apt install -y snapd
  fi

  # Docker
  log_info "Installing Docker"
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker "$USER"

  # Typora, Go, SecLists
  log_info "Installing Typora, Go, SecLists"
  sudo snap install typora
  sudo snap install go --classic
  sudo snap install seclists

  # Tmux plugin
  log_info "Installing tmux-mem-cpu-load"
  TMPDIR=$(mktemp -d)
  git clone https://github.com/thewtex/tmux-mem-cpu-load "$TMPDIR"
  cd "$TMPDIR"
  cmake . && make && sudo make install
  cd -
  rm -rf "$TMPDIR"

  echo 'set -g mouse on' >> ~/.tmux.conf

  # Oh My Zsh + powerlevel10k
  log_info "Installing Oh My Zsh"
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  chsh -s "$(which zsh)"

  log_info "Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

  sudo apt autoremove -y
}

install_pwn() {
  log_info "Installing pwn tools"
  sudo apt install -y nasm qemu-utils patchelf cmake qemu-user-static gdb-multiarch qemu-user musl-tools

  log_info "Installing Ruby-based tools"
  sudo gem install seccomp-tools one_gadget evil-winrm wpscan

  log_info "Installing pwntools and extras"
  python3 -m pip install --upgrade pip --break-system-packages
  python3 -m pip install --upgrade pwntools flask termcolor ropper ropgadget checksec.py tqdm pypykatz fierce \
    --break-system-packages

  log_info "Installing pwndbg"
  git clone https://github.com/pwndbg/pwndbg
  cd pwndbg
  ./setup.sh
  cd ..

  log_info "Installing pwninit"
  if ! command -v cargo &> /dev/null; then
    log_info "Installing Rust & Cargo"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
  cargo install pwninit
}

install_web() {
  log_info "Installing web tools"
  sudo apt install -y nmap nbd-client cupp php proxychains dnsmap lolcat sqlmap ffuf dnsenum snmp braa onesixtyone \
    mysql-server cryptsetup ettercap-graphical wfuzz smbmap smbclient dislocker ldap-utils sshuttle

  log_info "Installing Metasploit"
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod 755 msfinstall
  ./msfinstall

  log_info "Installing searchsploit"
  sudo snap install searchsploit
}

install_dot() {
  log_info "Installing dotfiles"

  # .zshrc
  log_info "Installing .zshrc"
  wget -O ~/.zshrc https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/dotfiles/.zshrc

  # .tmux.conf
  log_info "Installing .tmux.conf"
  wget -O ~/.tmux.conf https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/dotfiles/.tmux.conf

  # Nerd fonts
  log_info "Installing Nerd Fonts"
  sudo mkdir -p /usr/share/fonts/nerd
  sudo svn export https://github.com/w3th4nds/Helping-Hand/trunk/dotfiles/nerd /usr/share/fonts/nerd
  sudo fc-cache -vf

  log_info "Installing Neovim and config"
  bash <(curl -sSL https://raw.githubusercontent.com/w3th4nds/Helping-Hand/main/nvim_install.sh)
}

install_all() {
  install_pwn
  install_web
  install_dot
}

# === Parse flags ===
run_pwn=false
run_web=false
run_dot=false
run_all=false

if [ "$#" -eq 0 ]; then
  usage
fi

while [[ "$1" != "" ]]; do
  case $1 in
    --all ) run_all=true ;;
    --pwn ) run_pwn=true ;;
    --web ) run_web=true ;;
    --dot ) run_dot=true ;;
    --com ) install_com; exit 0 ;;
    * ) usage ;;
  esac
  shift
done

# === Always run common setup first ===
install_com

# === Then run selected components ===
$run_all && install_all
$run_pwn && install_pwn
$run_web && install_web
$run_dot && install_dot

log_info "Installation Finished Successfully"