#!/usr/bin/bash
#use xlsfonts to find fonts
# 定义一个更新间隔，例如 2 秒
#./c |lemonbar -f "variable"
UPDATE_INTERVAL=1

while true; do
    # 1. CPU 和内存 (左侧或中间)
    cpu=$(sar -u 1 1 | tail -1 | awk '{printf "%.2f%%", 100 - $NF}')
    mem=$(sar -r 1 1 | tail -1 | awk '{printf "%.2f%%", $5}')
    
    # 2. 网络 (右侧)
    # nmcli 的输出可能有多行且包含接口名，我们只抓取第一个连接名
    net=$(nmcli -g CONNECTION device status | head -n 1 | awk -F ':' '{print $1}')
    
    # 3. 音量
    # 简化音量输出到一个变量
    vol=$(echo -n $(LANG=C pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'&&echo "(" &&echo $(pactl get-sink-mute @DEFAULT_SINK@) && echo ")" && echo $(pactl get-default-sink)))
    
    # 4. 日期/时间 (居中)
    date_time=$(date '+%Y/%m/%d %H:%M:%S')

    # 5. 格式化 Lemonbar 输出：所有内容在单行上，用 %{l}, %{c}, %{r} 分隔
    # %{l} 左对齐 | %{c} 居中 | %{r} 右对齐
    
    # 将多个命令的输出组合成一行：
    echo "%{r}cpu:${cpu} | mem:${mem} | ${net} | ${vol} | ${date_time} "

    # 延迟，等待下次更新
    sleep $UPDATE_INTERVAL
done
