#!/bin/bash
#
# a simple dmenu session script
#
###
choice=$(default-terminal -e | echo -e "lock\nsuspend\nhibernate\nreboot\nshutdown\nlogout" | dmenu -p 'thinking about leaving? ')

case "$choice" in
  lock) /usr/bin/slock & ;;
  suspend) systemctl suspend & ;;
  hibernate) systemctl hibernate & ;;
  reboot) shutdown -r now & ;;
  shutdown) shutdown -h now & ;;
  logout) systemctl restart gdm & ;; #gdm, sddm or whatever login manager is running
esac
