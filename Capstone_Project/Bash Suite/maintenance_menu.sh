#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


if [[ ! -t 0 ]]; then
  echo "This script requires an interactive terminal. Run it from a terminal, not cron or a background job."
  exit 1
fi


BASE_DIR="${HOME}/bashsuite"
BIN_DIR="$BASE_DIR/bin"

PS3="Choose an action (number) > "

options=(
  "Run backup (default targets)"
  "Run backup (choose directory)"
  "Run update & cleanup"
  "Run log monitor (default)"
  "Run all (backup + update + log monitor)"
  "Schedule daily backup (add cron)"
  "Exit"
)


if [ "${#options[@]}" -eq 0 ]; then
  echo "No menu options available. Exiting."
  exit 2
fi

function run_backup_default {
  "$BIN_DIR/backup.sh"
}

function run_backup_custom {
  read -r -p "Enter source directory to backup: " src
  read -r -p "Enter destination directory (press enter for default): " dest
  "$BIN_DIR/backup.sh" "$src" "$dest"
}

function run_update_cleanup {
  "$BIN_DIR/update_cleanup.sh"
}

function run_log_monitor {
  read -r -p "Enter search term (default ERROR): " term
  term="${term:-ERROR}"
  "$BIN_DIR/log_monitor.sh" "" "$term"
}

function schedule_backup_cron {
  (crontab -l 2>/dev/null | grep -v 'bsuite/bin/backup.sh' ; echo "30 2 * * * $HOME/bsuite/bin/backup.sh") | crontab -
  echo "Cron job added: daily backup at 02:30"
}

# Display menu and read choice
select opt in "${options[@]}"; do
  case $REPLY in
    1) run_backup_default; break ;;
    2) run_backup_custom; break ;;
    3) run_update_cleanup; break ;;
    4) run_log_monitor; break ;;
    5) run_backup_default; run_update_cleanup; run_log_monitor; break ;;
    6) schedule_backup_cron; break ;;
    7) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option: $REPLY. Please enter a number between 1 and ${#options[@]}." ;;
  esac
done

