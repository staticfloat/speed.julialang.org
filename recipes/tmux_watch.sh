#!/bin/bash
# A convenience script to start up tmux shells running watch_commit_folder, along with nginx and uwsgi logs

source common.sh

if [[ -z "$(which tmux)" ]]; then
    echo "ERROR: tmux not installed!" 1>&2
    exit 1
fi

# nest tmux sessions with care....
OLD_TMUX=$TMUX
unset TMUX

tmux new-session -d -s "_watch"
tmux new-window -d -k -n "watch_commit" -t "_watch:0"
tmux send-keys -t "_watch:0" "cd $RECIPE_DIR; ./watch_commit_folder.sh" C-m

UWSGI_LOG="/tmp/uwsgi_travis-hook.log"
NGINX_LOG="/var/log/nginx/access.log"
if [[ "$(uname)" == "Darwin" ]]; then
    UWSGI_LOG="/usr/local/var/log/uwsgi_travis-hook.log"
    NGINX_LOG="/usr/local/var/log/nginx/*.log"
fi

tmux new-window -d -n "logs" -t "_watch:1"
tmux send-keys -t "_watch:1" "tail -f $UWSGI_LOG" C-m
tmux split-window -d -v -t "_watch:1"
tmux send-keys -t "_watch:1.1" "tail -f $NGINX_LOG" C-m

export TMUX=$OLD_TMUX
