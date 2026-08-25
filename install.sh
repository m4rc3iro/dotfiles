#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MACOS_PKGS=(git zsh tmux ranger btop neovim lazygit rcm)
MACOS_CASKS=(alacritty)

ARCH_PKGS=(git zsh tmux ranger btop neovim lazygit gcc xmonad xmonad-contrib picom rofi redshift alacritty)
ARCH_AUR_PKGS=(rcm) # not in the official repos

# Debian/Ubuntu boxes in this repo are headless, so no GUI stack here.
DEBIAN_PKGS=(git zsh tmux ranger btop curl build-essential rcm)
DEBIAN_GITHUB_PKGS=(neovim lazygit) # not reliably packaged for apt

detect_arch() {
  case "$(uname -m)" in
    x86_64) echo x86_64 ;;
    aarch64|arm64) echo arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
}

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi
  brew install "${MACOS_PKGS[@]}"
  brew install --cask "${MACOS_CASKS[@]}"
}

install_arch() {
  sudo pacman -S --needed "${ARCH_PKGS[@]}"
  if ! command -v paru &>/dev/null; then
    echo "paru not found. Install an AUR helper, then re-run this script to get: ${ARCH_AUR_PKGS[*]}" >&2
    exit 1
  fi
  paru -S --needed "${ARCH_AUR_PKGS[@]}"
}

# Ubuntu's apt neovim (and even neovim-ppa/stable, stuck on 0.7.2 for a long
# time) is too old for lazy.nvim (needs >=0.8.0), so install it straight from
# the official GitHub release binary instead of any Debian/Ubuntu package.
install_github_release_neovim() {
  local arch tarball
  arch="$(detect_arch)"
  tarball="/tmp/nvim-linux-${arch}.tar.gz"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" -o "$tarball"
  sudo rm -rf "/opt/nvim-linux-${arch}"
  sudo tar -xzf "$tarball" -C /opt
  sudo ln -sf "/opt/nvim-linux-${arch}/bin/nvim" /usr/local/bin/nvim
  rm "$tarball"
}

# lazygit isn't in the default Debian/Ubuntu repos, so install it the same
# way its own docs recommend: latest GitHub release binary.
install_github_release_lazygit() {
  local arch version tarball
  arch="$(detect_arch)"
  version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
  tarball="/tmp/lazygit.tar.gz"
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz" -o "$tarball"
  tar -xzf "$tarball" -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin/lazygit
  rm "$tarball" /tmp/lazygit
}

install_debian() {
  sudo apt-get update
  sudo apt-get install -y "${DEBIAN_PKGS[@]}"
  for pkg in "${DEBIAN_GITHUB_PKGS[@]}"; do
    "install_github_release_${pkg}"
  done
}

install_linux() {
  if command -v pacman &>/dev/null; then
    install_arch
  elif command -v apt-get &>/dev/null; then
    install_debian
  else
    echo "No supported package manager found (expected pacman or apt-get)." >&2
    exit 1
  fi
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

install_tpm

cd "$DOTFILES_DIR"
rcup -v
