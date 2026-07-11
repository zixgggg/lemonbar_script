#!/bin/bash

# 清理舊的殘留監聽
pkill -f "xprop -root -spy" 2>/dev/null

# 函數：獲取當前工作區名稱和視窗標題並輸出
update_title() {
    # 1. 取得當前工作區索引 (從 0 開始的數字，例如 0 代表工作區 1)
    # xprop 輸出的格式通常是 _NET_CURRENT_DESKTOP(CARDINAL) = 0
    desktop_idx=$(xprop -root _NET_CURRENT_DESKTOP | awk -F '= ' '{print $2}')
    
    # 因為你的 bspwm 工作區是 1 2 3...0，把索引 +1 配合你的習慣
    # 如果索引是空的，預設為 1
    if [ -n "$desktop_idx" ]; then
        current_workspace=$((desktop_idx + 1))
        # 配合 bspwm 的第 10 個工作區顯示為 0
        [ "$current_workspace" -eq 10 ] && current_workspace=0
    else
        current_workspace="1"
    fi

    # 2. 取得當前視窗標題
    window_id=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$window_id" ] && [ "$window_id" -gt 0 ] 2>/dev/null; then
        title=$(xdotool getwindowname "$window_id" 2>/dev/null)
        [ -z "$title" ] && title="Desktop"
    else
        title="Desktop"
    fi

    # 限制標題長度
    #[ ${#title} -gt 50 ] && title="${title:0:47}..."

    # 3. 輸出給 lemonbar
    echo "[$current_workspace]  $title"
}

# 首次啟動先執行一次，避免剛打開時一片空白
update_title

# 用 -spy 同時監聽當前桌面變更與視窗變更
# 當任何一個值改變，read 就會觸發更新
xprop -root -spy _NET_CURRENT_DESKTOP _NET_ACTIVE_WINDOW | while read -r line; do
    update_title
done
