#!/usr/bin/env bash

SESSION="kursdemo"
TARGET="$SESSION"   # Wichtig: nicht :0.0, nur die Session

menu() {
  whiptail --title "Kurssteuerung" --menu "Aktion wählen:" 20 60 10 \
    "1" "Demo: ls und pwd eingeben" \
    "2" "nano mit Datei öffnen" \
    "3" "Kompilierbefehl vormachen" \
    "q" "Beenden" \
    3>&1 1>&2 2>&3
}

send_typewriter() {
  local target="$1"
  local text="$2"
  local delay="${3:-0.05}"
  local i c
  for ((i=0; i<${#text}; i++)); do
    c="${text:$i:1}"
    tmux send-keys -t "$target" "$c"
    sleep "$delay"
  done
}

while true; do
  CHOICE=$(menu) || exit 0

  case "$CHOICE" in
    1)
      send_typewriter "$TARGET" "ls"
      tmux send-keys -t "$TARGET" C-m
      sleep 1
      send_typewriter "$TARGET" "pwd"
      tmux send-keys -t "$TARGET" C-m
      ;;
    2)
      send_typewriter "$TARGET" "nano demo.py"
      tmux send-keys -t "$TARGET" C-m
      ;;
    3)
      send_typewriter "$TARGET" "python3 demo.py --flag1 --verbose"
      tmux send-keys -t "$TARGET" C-m
      ;;
    q) break ;;
  esac
done

