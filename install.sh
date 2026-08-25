#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMON_PKGS=(git zsh neovim tmux ranger btop)
ARCH_PKGS=(xmonad xmonad-contrib picom rofi redshift alacritty)
AUR_PKGS=(rcm)

install_macos() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi
  brew install "${COMMON_PKGS[@]}" rcm
  brew install --cask alacritty
}

install_arch() {
  sudo pacman -S --needed "${COMMON_PKGS[@]}" "${ARCH_PKGS[@]}"
  if ! command -v paru &>/dev/null; then
    echo "paru not found. Install an AUR helper, then re-run this script to get: ${AUR_PKGS[*]}" >&2
    exit 1
  fi
  paru -S --needed "${AUR_PKGS[@]}"
}

install_debian() {
  # No GUI packages here (xmonad/picom/rofi/redshift/alacritty) - that stack
  # is for the Arch desktop; Debian/Ubuntu boxes in this repo are headless.
  sudo apt-get update
  sudo apt-get install -y "${COMMON_PKGS[@]}" rcm
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
