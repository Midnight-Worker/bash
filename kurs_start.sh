#!/usr/bin/env bash

SESSION="kursdemo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX_DIR="$SCRIPT_DIR/sandbox"

mkdir -p "$SANDBOX_DIR"

PANE_STUDENT_FILE="/tmp/kursdemo_student_pane"
PANE_CONTROL_FILE="/tmp/kursdemo_control_pane"
PANE_MDP_FILE="/tmp/kursdemo_mdp_pane"

# Wenn Session schon existiert: einfach attachen
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

# Neue Session mit einem Pane (oben links)
#tmux new-session -d -s "$SESSION" -n main 'bash --login'


# Aktives Pane ist jetzt oben links
#TOP_LEFT=$(tmux display-message -p -t "$SESSION:main" '#{pane_id}')

# Vertikal splitten: neues Pane unten (Schüler)
#tmux split-window -v -t "$SESSION:main" 'bash --login'
#BOTTOM=$(tmux display-message -p -t "$SESSION:main" '#{pane_id}')

# Neue Session mit einem Pane (oben links) – Lehrerbereich startet im Kursordner
tmux new-session -d -s "$SESSION" -n main "cd \"$SCRIPT_DIR\" && bash --login"

# Aktives Pane ist jetzt oben links
TOP_LEFT=$(tmux display-message -p -t "$SESSION:main" '#{pane_id}')

# Vertikal splitten: neues Pane unten (Schüler) – startet im sandbox-Verzeichnis
tmux split-window -v -t "$SESSION:main" "cd \"$SANDBOX_DIR\" && bash --login"
BOTTOM=$(tmux display-message -p -t "$SESSION:main" '#{pane_id}')

# Zurück zum oberen Pane (Lehrerbereich)
tmux select-pane -t "$TOP_LEFT"

# Oben horizontal splitten: rechts mdp-Pane
tmux split-window -h -t "$SESSION:main" 'bash --login'
TOP_RIGHT=$(tmux display-message -p -t "$SESSION:main" '#{pane_id}')

# Pane-IDs speichern
echo "$BOTTOM"    > "$PANE_STUDENT_FILE"
echo "$TOP_LEFT"  > "$PANE_CONTROL_FILE"
echo "$TOP_RIGHT" > "$PANE_MDP_FILE"

# Im Steuerpane (oben links) den Kurscontroller starten
tmux send-keys -t "$TOP_LEFT" "cd \"$SCRIPT_DIR\" && ./course_control.sh" C-m

# Fokus auf Steuerpane setzen und Session anzeigen
tmux select-pane -t "$TOP_LEFT"
tmux attach -t "$SESSION"

