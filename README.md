# Dotfiles

> rcup man page: https://www.mankier.com/1/rcup

## Setup

1. Clone repo into EXACTLY **~/.dotfiles**: `git clone https://github.com/m4rc3iro/dotfiles.git ~/.dotfiles`
1. Run `./install.sh` — installs rcm and the packages the configs assume (brew on macOS, pacman/paru on Arch Linux), bootstraps tmux's plugin manager (TPM), then symlinks everything with `rcup`
   - On Debian/Ubuntu (apt), it only installs CLI tools (git, zsh, neovim, tmux, ranger, btop, rcm) — GUI tooling (xmonad, picom, rofi, redshift, alacritty) is Arch/macOS-only in the script and needs to be installed manually if you want it on a Debian/Ubuntu desktop

## Managing configs

- To apply/update a single config, **navigate to ~/.dotfiles** and run `rcup -v <file/folder>` e.g. "rcup -v config/nvim"
- To backup config run `mkrc -v ~/.zshrc`

## References
> https://disro.tube/guest-articles/managing-dotfiles-with-rcm.html
