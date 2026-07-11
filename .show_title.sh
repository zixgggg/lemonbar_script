#!/bin/bash
xprop -root -spy _NET_ACTIVE_WINDOW | while read -r line; do
    # 取得當前視窗 ID
    window_id=$(xdotool getactivewindow 2>/dev/null)
    
    # 確保 window_id 不是空的，也不是 0
    if [ -n "$window_id" ] && [ "$window_id" -gt 0 ] 2>/dev/null; then
        title=$(xdotool getwindowname "$window_id" 2>/dev/null)
        [ -z "$title" ] && title="Desktop"
        
        # 限制長度
        #[ ${#title} -gt 50 ] && title="${title:0:47}..."
        echo "$title"
    else
        echo "desktop"
    fi
done
#~/.show_title.sh|lemonbar -f notocjk
