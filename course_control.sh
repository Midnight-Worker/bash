#!/usr/bin/env bash

#!/usr/bin/env bash

# Dezentes Farbschema für whiptail
export NEWT_COLORS='
window=white,black
border=white,black
textbox=white,black
button=white,black
'
export TERM=vt100

sleep 0.3

SESSION="kursdemo"

PANE_STUDENT_FILE="/tmp/kursdemo_student_pane"
PANE_CONTROL_FILE="/tmp/kursdemo_control_pane"
PANE_MDP_FILE="/tmp/kursdemo_mdp_pane"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$PANE_STUDENT_FILE" ] || [ ! -f "$PANE_MDP_FILE" ]; then
  echo "Pane-Infos fehlen. Bitte ./kurs_start.sh benutzen." >&2
  exit 1
fi

STUDENT_PANE="$(cat "$PANE_STUDENT_FILE")"
MDP_PANE="$(cat "$PANE_MDP_FILE")"

menu() {
  whiptail --title "Kurssteuerung" --menu "Aktion wählen:" 20 70 12 \
    "1" "Slides starten (mdp vortrag.md)" \
    "2" "Nächste Folie" \
    "3" "Vorherige Folie" \
    "4" "Slides beenden" \
    "5" "Demo: ls & pwd im Schüler-Pane" \
    "6" "nano demo.py im Schüler-Pane" \
    "7" "Python-Kompilierdemo im Schüler-Pane" \
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
      # mdp im Lehrer-MDP-Pane starten
      tmux send-keys -t "$MDP_PANE" "cd \"$SCRIPT_DIR\" && mdp vortrag.md" C-m
      ;;
    2)
      # nächste Folie (Space)
      tmux send-keys -t "$MDP_PANE" ' '
      ;;
    3)
      # vorherige Folie (Pfeil hoch)
      tmux send-keys -t "$MDP_PANE" Up
      ;;
    4)
      # Slides beenden (q)
      tmux send-keys -t "$MDP_PANE" q
      ;;
    5)
      send_typewriter "$STUDENT_PANE" "ls"
      tmux send-keys -t "$STUDENT_PANE" C-m
      sleep 1
      send_typewriter "$STUDENT_PANE" "pwd"
      tmux send-keys -t "$STUDENT_PANE" C-m
      ;;
    6)
      send_typewriter "$STUDENT_PANE" "nano demo.py"
      tmux send-keys -t "$STUDENT_PANE" C-m
      ;;
    7)
      send_typewriter "$STUDENT_PANE" "python3 demo.py --flag1 --verbose"
      tmux send-keys -t "$STUDENT_PANE" C-m
      ;;
    q)
      tmux kill-session -t "$SESSION"
      exit 0
      ;;
  esac
done

