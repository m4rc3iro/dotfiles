if status is-interactive
    # Commands to run in interactive sessions can go here
end

## Alias section 
alias btop 'bashtop'                                                # Confirm before overwriting something
alias vim 'nvim'
alias cp 'cp -i'                                                # Confirm before overwriting something
alias df 'df -h'                                                # Human-readable sizes
alias free 'free -m'                                            # Show sizes in MB
alias ll 'ls -l'
alias la 'ls -la'
alias hg 'history | grep '
alias psef 'ps -ef | grep '
alias upd 'paru -Syu'
alias updm 'mw -Y'
alias pi 'paru -S'
alias pr 'paru -R'
alias psr 'paru -Ss'
alias psl 'paru -Qs'
alias rfc 'source ~/.config/fish/config.fish'
alias rpc 'source ~/.profile'
alias rpcc 'sudo killall picom; picom &'
alias epcc 'vim ~/.config/picom.conf'
alias efc 'vim ~/.config/fish/config.fish'
alias exc 'vim ~/.xmonad/xmonad.hs'
alias exbc 'vim ~/.xmonad/xmobarrc'
alias svim 'sudo vim'
alias bctl 'bluetoothctl'
alias cbhs 'ssh runmarcm@162.241.226.34'
alias rwn 'sh ~/.local/bin/scripts/restart-network-macpro'

# go to aliases
alias ggr 'cd ~/git-repositories'
alias gdoc 'cd ~/Documents'
alias gpic 'cd ~/Pictures'
alias gdesk 'cd ~/Desktop'
alias gdown 'cd ~/Downloads'
alias gvid 'cd ~/Videos'
alias gxh 'cd ~/.xmonad'
alias gxorgh 'cd /etc/X11/xorg.conf.d'
alias gfh 'cd ~/.config/fish'
alias gdfh 'cd ~/.dotfiles'
alias gdwm 'cd ~/repositories/suckless/dwm/'
alias gdwmc 'cd ~/.config/dwm/'
alias glc 'cd ~/.config'
alias glbs 'cd ~/.local/bin/scripts/'
alias gusx 'cd /usr/share/xsessions'

alias skll 'sudo killall'
#alias mkcdir 'f() { mkdir $1 && cd $1 };f'

# wifi aliases
alias wls 'nmcli device wifi list'
#alias wc 'f() { nmcli device wifi connect $1 password $2 };f'
alias wc1 'nmcli device wifi connect UPC8507569 password WW72yavuktmp'
alias wc2 'nmcli device wifi connect UPC8507569_EXT password WW72yavuktmp'
alias wc3 'nmcli d wifi connect Monia password Zamek12!'

# network
alias rnms 'sudo systemctl stop NetworkManager.service && sudo systemctl start NetworkManager.service'

# nordvpn
alias nvpncf 'nordvpn connect frankfurt'
alias nvpncb 'nordvpn connect berlin'
alias nvpncz 'nordvpn connect zurich'
alias nvpnccr 'nordvpn connect czech_republic'
alias nvpnc 'nordvpn connect'
alias nvpnd 'nordvpn disconnect'
alias nvpns 'nordvpn status'
