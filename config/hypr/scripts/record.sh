#!/usr/bin/env bash
# Toggle screen recording. Usage: record.sh [--fullscreen] [--sound]
dir="$(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Videos")/Recordings"
if pgrep -x wf-recorder >/dev/null; then
  pkill -INT -x wf-recorder
  notify-send "Recording stopped" "Saved in $dir" -a Recorder
  exit 0
fi
mkdir -p "$dir"
out="$dir/recording_$(date +%Y-%m-%d_%H.%M.%S).mp4"
args=()
fullscreen=0
for a in "$@"; do
  case "$a" in
    --fullscreen) fullscreen=1 ;;
    --sound) args+=(--audio) ;;
  esac
done
if [ "$fullscreen" = 0 ]; then
  region="$(slurp)" || exit 0
  args+=(-g "$region")
fi
notify-send "Recording started" -a Recorder
exec wf-recorder "${args[@]}" -f "$out"
