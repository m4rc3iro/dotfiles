#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMON_PKGS=(git zsh tmux ranger btop)
ARCH_PKGS=(xmonad xmonad-contrib picom rofi redshift alacritty)
AUR_PKGS=(rcm)

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi
  brew install "${COMMON_PKGS[@]}" neovim rcm
  brew install --cask alacritty
}

install_arch() {
  sudo pacman -S --needed "${COMMON_PKGS[@]}" neovim "${ARCH_PKGS[@]}"
  if ! command -v paru &>/dev/null; then
    echo "paru not found. Install an AUR helper, then re-run this script to get: ${AUR_PKGS[*]}" >&2
    exit 1
  fi
  paru -S --needed "${AUR_PKGS[@]}"
}

# Ubuntu's apt neovim (and even neovim-ppa/stable, stuck on 0.7.2 for a long
# time) is too old for lazy.nvim (needs >=0.8.0), so install it straight from
# the official GitHub release binary instead of any Debian/Ubuntu package.
install_neovim_github() {
  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo "No prebuilt neovim binary for architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  local tarball="/tmp/nvim-linux-${arch}.tar.gz"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" -o "$tarball"
  sudo rm -rf "/opt/nvim-linux-${arch}"
  sudo tar -xzf "$tarball" -C /opt
  sudo ln -sf "/opt/nvim-linux-${arch}/bin/nvim" /usr/local/bin/nvim
  rm "$tarball"
}

install_debian() {
  # No GUI packages here (xmonad/picom/rofi/redshift/alacritty) - that stack
  # is for the Arch desktop; Debian/Ubuntu boxes in this repo are headless.
  sudo apt-get update
  sudo apt-get install -y "${COMMON_PKGS[@]}" curl rcm
  install_neovim_github
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
