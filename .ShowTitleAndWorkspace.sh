#!/bin/bash

# 清理舊的殘留監聽
pkill -f "xprop -spy" 2>/dev/null

# 函數：純粹用來輸出當前的 [工作區] + 標題
print_status() {
    # 1. 取得當前工作區索引 (對齊 bspwm 的 1 2 3...0)
    desktop_idx=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk -F '= ' '{print $2}')
    if [ -n "$desktop_idx" ]; then
        current_workspace=$((desktop_idx + 1))
        [ "$current_workspace" -eq 10 ] && current_workspace=0
    else
        current_workspace="1"
    fi

    # 2. 取得當前視窗標題
    local win_id=$1
    if [ -n "$win_id" ] && [ "$win_id" -gt 0 ] 2>/dev/null; then
        title=$(xdotool getwindowname "$win_id" 2>/dev/null)
        [ -z "$title" ] && title="Desktop"
    else
        title="Desktop"
    fi

    # 3. 輸出給 lemonbar
    echo "[$current_workspace]  $title"
}

# 核心監聽邏輯
# 步驟 A: 先盯著「焦點視窗有沒有換」跟「有沒有換工作區」
xprop -root -spy _NET_ACTIVE_WINDOW _NET_CURRENT_DESKTOP | while read -r line; do
    
    # 拿到當前最新的 active window ID
    current_win=$(xdotool getactivewindow 2>/dev/null)
    
    # 先立刻更新一次畫面 (不管是換了工作區還是換了視窗)
    print_status "$current_win"
    
    # 步驟 B: 如果當前有聚焦在實體視窗上，就開一個「非同步子進程」單獨死盯它的標題變更
    if [ -n "$current_win" ] && [ "$current_win" -gt 0 ] 2>/dev/null; then
        
        # 殺掉上一個視窗的標題監聽進程，避免殭屍堆疊
        pkill -f "xprop -spy -id" 2>/dev/null
        
        # 開啟新監聽：只要這個視窗的名稱 (_NET_WM_NAME) 改變
        (
            xprop -spy -id "$current_win" _NET_WM_NAME 2>/dev/null | while read -r _; do
                # 標題變了，立刻重新印出狀態
                print_status "$current_win"
            done
        ) &
    fi
done
