#!/usr/bin/env bash

SESSION="kursdemo"
PANE_FILE="/tmp/kursdemo_student_pane"

if [ ! -f "$PANE_FILE" ]; then
  echo "Studenten-Pane wurde nicht gefunden ($PANE_FILE)." >&2
  exit 1
fi

TARGET="$(cat "$PANE_FILE")"   # tmux-pane-id des unteren Panes

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
	  sleep 1
      send_typewriter "$TARGET" "ls"
      sleep 1
	  tmux send-keys -t "$TARGET" C-m
      sleep 1
      send_typewriter "$TARGET" "pwd"
	  sleep 1
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
    q)
      break
      ;;
  esac
done

