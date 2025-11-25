# start_student.sh
#!/usr/bin/env bash

SESSION="kursdemo"

# neue tmux-Session im Hintergrund starten
tmux new-session -d -s "$SESSION" 'bash --login'

echo "tmux-Session '$SESSION' gestartet."
echo "Schüler-Bash siehst du mit:"
echo "  tmux attach -t $SESSION"

