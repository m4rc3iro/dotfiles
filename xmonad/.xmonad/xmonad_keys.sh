#!/usr/bin/env bash
set -euo pipefail

sed -n '/START_KEYS/,/END_KEYS/p' ~/.xmonad/xmonad.hs | grep -e ', (' -e '\[ (' -e '\-\-' | grep -v '\-\- , (' | yad --text-info --back=#282c34 --fore=#46d9ff --geometry=1200x800 --no-buttons --borders=0
