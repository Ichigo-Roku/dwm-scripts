_bat() {
    bat=`cat /sys/class/power_supply/BAT0/capacity`
    bat=`echo -e "\x01battery\x06$bat%"`
}

_date() {
    date=$(date '+%A, %B %d')
    date=`echo -e "\x01$date"`
}

_kbd() {
    max=`cat /sys/class/leds/smc::kbd_backlight/max_brightness`
    actual=`cat /sys/class/leds/smc::kbd_backlight/brightness`
    kbd=`echo $(( ($actual * 100) / $max ))`
    kbd=`echo -e "\x01keyboard\x06$kbd%"`
}

_kernel() {
    kernel=`uname -r`
    kernel=`echo -e "\x01linux\x06$kernel"`
}

_moc() {
    if [ -z $(mocp -Q %state | grep PLAY) ]; then
	moc=`echo -e "\x01music\x06off"`
    else
	art=$(mocp -Q %artist)
	tit=$(mocp -Q %song)
	moc=`echo -e "\x01listening\x06$tit\x01from\x06$art"`
    fi
}

_screen() {
    max=`cat /sys/class/backlight/intel_backlight/max_brightness`
    actual=`cat /sys/class/backlight/intel_backlight/actual_brightness`
    screen=`echo $(( ($actual * 100) / $max ))`
    screen=`echo -e "\x01screen\x06$screen%"`
}

_time() {
    time=$(date '+%I:%M%P')
    time=`echo -e "\x06$time"`
}

_uptime() {
    uptime=$(cut -d'.' -f1 /proc/uptime)
    mins=$((${uptime}/60%60))
    hours=$((${uptime}/3600%24))
    days=$((${uptime}/86400))
    uptime="${mins}m"
    if [ "${hours}" -ne "0" ]; then
	uptime="${hours}h${uptime}m"
    fi
    if [ "${days}" -ne "0" ]; then
	uptime="${days}d${uptime}"
    fi
    uptime=`echo -e "\x01uptime\x06$uptime"`
}

_volume() {
    status=$(amixer get Master | grep "Mono: P" | awk '{print $6}')
    if [ "$status" = "[on]" ] ; then
	volume=$(amixer get Master | grep "Mono: P" | awk '{print $4}' | grep -oE "[[:digit:]]{1,}"%)
	volume=`echo -e "\x01volume\x06$volume"`
    else
	volume=`echo -e "\x01volume\x06muted"`
    fi
}

status() {
    for arg in $@; do
	_${arg}
	args="${args}  `eval echo '$'$arg`"
    done
    echo "$args"
}

status volume bat kbd screen moc kernel uptime date time
