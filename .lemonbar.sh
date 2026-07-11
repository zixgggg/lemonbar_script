while [ true ];do
	time=$(date)
	#volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'&&echo -n "(" &&echo $(pactl get-sink-mute @DEFAULT_SINK@) && echo -n ")" && echo $(pactl get-default-sink))
	vol_num=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')
	vol_mute=$(echo -n "(" &&echo -n $(pactl get-sink-mute @DEFAULT_SINK@) && echo -n ")")
	vol_dev=$(pactl get-default-sink)
	network=$(LANG=C nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
	lock_time=$(xssstate -t)
	echo "$time    |    volume:$vol_num $vol_mute $vol_dev    |    network:$network    |    lock:$lock_time"
	sleep 0.5
done
#~/.lemonbar.sh |lemonbar -f notocjk -b
