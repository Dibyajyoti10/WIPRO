
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


LOGDIR="${HOME}/bashsuite_logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/log_monitor.log"
REPORT="$LOGDIR/log_report_$(date +%Y%m%d_%H%M%S).txt"

default_term="ERROR"
default_minutes=2880

if [ -f /var/log/syslog ]; then
  system_log="/var/log/syslog"
elif [ -f /var/log/messages ]; then
  system_log="/var/log/messages"
else
  system_log=""
fi

input_log="${1:-$system_log}"
search_term="${2:-$default_term}"
since_minutes="${3:-$default_minutes}"

if [ -z "$input_log" ]; then
  echo "No system log found and no logfile provided." | tee -a "$LOGFILE"
  exit 2
fi

echo "[$(date)] Scanning $input_log for '$search_term' in last $since_minutes minutes..." | tee -a "$LOGFILE"

if command -v journalctl >/dev/null 2>&1; then
  echo "Using journalctl to fetch logs" | tee -a "$LOGFILE"
  journalctl --since "${since_minutes} minutes ago" --no-pager | grep -i --color=never -E "$search_term" | tee "$REPORT"
else
  grep -i --binary-files=text -E "$search_term" "$input_log" | tee "$REPORT"
fi

count=$(wc -l < "$REPORT" || true)
echo "[$(date)] Found $count matching lines. Report saved to $REPORT" | tee -a "$LOGFILE"



exit 0
