#!/usr/bin/env bash

SESSION="kursdemo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANE_FILE="/tmp/kursdemo_student_pane"

# Wenn Session schon existiert: einfach attachen
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

# Neue Session im Hintergrund starten, erstes Pane (oben)
tmux new-session -d -s "$SESSION" -n main 'bash --login'

# Zweites Pane (unten) vertikal splitten
tmux split-window -v -t "$SESSION:main" 'bash --login'

# Pane-IDs ermitteln (robust, unabhängig von base-index)
PANE_INFO=$(tmux list-panes -t "$SESSION:main" -F '#{pane_index} #{pane_id}' | sort)
TOP_PANE=$(echo "$PANE_INFO"   | head -n1 | awk '{print $2}')
BOTTOM_PANE=$(echo "$PANE_INFO"| tail -n1 | awk '{print $2}')

# Unteres Pane (Schüler) merken, damit course_control es findet
echo "$BOTTOM_PANE" > "$PANE_FILE"

# Im oberen Pane die Kurssteuerung starten
tmux send-keys -t "$TOP_PANE" "cd \"$SCRIPT_DIR\" && ./course_control.sh" C-m

# Fokus auf Steuerungs-Pane setzen und attachen
tmux select-pane -t "$TOP_PANE"
tmux attach -t "$SESSION"

