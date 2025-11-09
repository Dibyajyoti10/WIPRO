#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'



SCRIPT_NAME="my_backup"
TIMESTAMP="$(date +'%Y-%m-%d_%H%M%S')"
USER_HOME="${HOME:-/home/$(whoami)}"
DEFAULT_SRC="$USER_HOME"
DEFAULT_DEST="$USER_HOME/bashsuite_backups"
LOGDIR="${HOME}/bashsuite_logs"
LOGFILE="$LOGDIR/backup.log"
RETENTION_DAYS=60

mkdir -p "$LOGDIR" "$DEFAULT_DEST"

src="${1:-$DEFAULT_SRC}"
dest="${2:-$DEFAULT_DEST}"
archive_name="backup_${TIMESTAMP}.tar.gz"
archive_path="$dest/$archive_name"

trap 'echo "[$(date)] ERROR: backup failed" >> "$LOGFILE"; exit 1' ERR

echo "[$(date)] Starting backup: $src -> $archive_path" | tee -a "$LOGFILE"

if [ ! -d "$src" ]; then
  echo "[$(date)] ERROR: source directory $src not found" | tee -a "$LOGFILE"
  exit 2
fi

mkdir -p "$dest"

tar -czf "$archive_path" -C "$(dirname "$src")" "$(basename "$src")"
echo "[$(date)] Backup archived to $archive_path" | tee -a "$LOGFILE"

find "$dest" -type f -name 'backup_*.tar.gz' -mtime +"$RETENTION_DAYS" -print -delete | tee -a "$LOGFILE"

echo "[$(date)] Backup completed successfully." | tee -a "$LOGFILE"
exit 0
