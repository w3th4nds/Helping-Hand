#!/bin/bash

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
  echo "  --com    Install common tools only. (This runs be default)"
  exit 1
}

# === Common setup ===
install_com() {
  log_info "Starting script, installing common tools"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y tree git curl zsh vim python3 python3-pip python3-dev libreoffice \
           libssl-dev libffi-dev build-essential libncurses-dev libguestfs-tools \
           ffmpeg open-vm-tools open-vm-tools-desktop gem gcc ruby-dev gcc-multilib default-jdk \
           fcrackzip ntfs-3g-dev jq nodejs p7zip-full net-tools ncdu \
           nfs-common whois perl vnstat freerdp2-x11 hashcat locate upx \
           pipx socat neofetch fping pkg-config elfutils xsel cmake liblzma-dev eza
  sudo apt autoremove -y

  # Docker
  log_info "Installing Docker"
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker ${USER}

  # Typora, Go, SecLists
  log_info "Installing Typora, Go, and SecLists"
  sudo snap install typora
  sudo snap install go
  sudo snap install seclists

  # SSH Key (skip if exists)
  if [ ! -f ~/.ssh/id_rsa ]; then
    log_info "Creating SSH keys"
    ssh-keygen -t rsa -b 4096 -C "your@email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
  else
    log_info "SSH key already exists. Skipping."
  fi

  # Git config (update these manually if needed)
  git config --global user.email "your@email"
  git config --global user.name "your_username"

  # Tmux plugins
  log_info "Installing tmux-mem-cpu-load"
  git clone https://github.com/thewtex/tmux-mem-cpu-load ~/.tmux-mem-cpu-load
  cd ~/.tmux-mem-cpu-load
  cmake . && make && sudo make install
  cd -

  echo 'set -g mouse on' >> ~/.tmux.conf

  # Oh My Zsh
  log_info "Installing Oh My Zsh"
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  chsh -s $(which zsh)

  sudo apt autoremove -y
}

# === Pwn tools ===
install_pwn() {
  log_info "Installing pwn tools"
  sudo apt install -y nasm qemu-utils patchelf cmake qemu-user-static gdb-multiarch qemu-user musl-tools

  log_info "Installing seccomp-tools, one_gadget, evil-winrm, wpscan"
  sudo gem install seccomp-tools one_gadget evil-winrm wpscan

  log_info "Installing pwntools and more"
  python3 -m pip install --upgrade pip --break-system-packages
  python3 -m pip install --upgrade pwntools flask termcolor ropper ropgadget checksec.py tqdm pypykatz fierce \
    --break-system-packages

  # pwndbg
  log_info "Installing pwndbg"
  git clone https://github.com/pwndbg/pwndbg
  cd pwndbg
  ./setup.sh
  cd ../

  # Rust + pwninit
  log_info "Installing pwninit"
  if ! command -v cargo &> /dev/null; then
    log_info "Installing Rust & Cargo"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
  fi
  cargo install pwninit
}

# === Web tools ===
install_web() {
  log_info "Installing web tools"
  sudo apt install -y nmap nbd-client cupp php proxychains dnsmap lolcat sqlmap ffuf dnsenum snmp braa onesixtyone \
           mysql-server cryptsetup ettercap-graphical wfuzz smbmap smbclient dislocker ldap-utils sshuttle

  # Metasploit
  log_info "Installing Metasploit Framework"
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod 755 msfinstall
  ./msfinstall

  # Searchsploit
  log_info "Installing searchsploit"
  sudo snap install searchsploit
}

# === Placeholder for dotfiles ===
install_dot() {
  log_info "Copying dot files"
  
}

# === Install all ===
install_all() {
  install_pwn
  install_web
  install_dot
}

# === Argument flags ===
run_pwn=false
run_web=false
run_dot=false
run_all=false

# === Parse arguments ===
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

# === Always install common tools ===
install_com

# === Run requested installations ===
$run_all && install_all
$run_pwn && install_pwn
$run_web && install_web
$run_dot && install_dot