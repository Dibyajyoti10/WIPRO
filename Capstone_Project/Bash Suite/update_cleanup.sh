#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOGDIR="${HOME}/bashsuite_logs"
LOGFILE="$LOGDIR/update_cleanup.log"
mkdir -p "$LOGDIR"
trap 'echo "[$(date)] ERROR: update script failed" >> "$LOGFILE"; exit 1' ERR

echo "[$(date)] Starting system update & cleanup" | tee -a "$LOGFILE"

if command -v apt >/dev/null 2>&1; then
  echo "Using apt package manager" | tee -a "$LOGFILE"
  sudo apt update | tee -a "$LOGFILE"
  sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade | tee -a "$LOGFILE"
  sudo apt -y autoremove | tee -a "$LOGFILE"
  sudo apt -y autoclean | tee -a "$LOGFILE"
  echo "[$(date)] apt update & cleanup done" | tee -a "$LOGFILE"

elif command -v dnf >/dev/null 2>&1; then
  echo "Using dnf package manager" | tee -a "$LOGFILE"
  sudo dnf -y upgrade --refresh | tee -a "$LOGFILE"
  sudo dnf -y autoremove | tee -a "$LOGFILE"
  echo "[$(date)] dnf update & cleanup done" | tee -a "$LOGFILE"

elif command -v yum >/dev/null 2>&1; then
  echo "Using yum" | tee -a "$LOGFILE"
  sudo yum -y update | tee -a "$LOGFILE"
  echo "[$(date)] yum update done" | tee -a "$LOGFILE"

else
  echo "No supported package manager (apt/dnf/yum) found. Exiting." | tee -a "$LOGFILE"
  exit 3
fi



echo "[$(date)] Update & cleanup finished successfully." | tee -a "$LOGFILE"
exit 0

