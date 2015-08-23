_bat() {
    bat=`cat /sys/class/power_supply/BAT0/capacity`
    bat=`echo -e "\x06battery $bat%"`
}

_volume() {
    status=$(amixer get Master | grep "Mono: P" | awk '{print $6}')
    if [ "$status" = "[on]" ] ; then
	volume=$(amixer get Master | grep "Mono: P" | awk '{print $4}' | grep -oE "[[:digit:]]{1,}"%)
	volume=`echo -e "\x05volume $volume"`
    else
	volume=`echo -e "\x05volume muted"`
    fi
}

_heure() {
    heure=$(date '+%I:%M %p')
    heure=`echo -e "\x01$heure"`
}

_date() {
    date=$(date '+%A, %B %d')
    date=`echo -e "\x06$date"`
}

_uptime() {
    uptime=$(cut -d'.' -f1 /proc/uptime)
    mins=$((${uptime}/60%60))
    hours=$((${uptime}/3600%24))
    days=$((${uptime}/86400))
    uptime="${mins}m"
    if [ "${hours}" -ne "0" ]; then
	uptime="${hours}h ${uptime}"
    fi
    if [ "${days}" -ne "0" ]; then
	uptime="${days}d ${uptime}"
    fi
    uptime=`echo -e "\x05uptime $uptime"`
}

_kernel() {
    kernel=`uname -r`
    kernel=`echo -e "\x01linux $kernel"`
}

_moc() {
    if [ -z $(mocp -Q %state | grep PLAY) ]; then
	moc=`echo -e "\x06music off"`
    else
	art=$(mocp -Q %artist)
	tit=$(mocp -Q %song)
	if [ $(echo "$art - $tit" | wc -m) -gt "99" ]; then
	    mus=$(echo "$tit from $art"  | cut -b 1-99)
	    moc=`echo -e "\x06listening to $mus..."`
	else
	    mus="$tit from $art"
	    moc=`echo -e "\x06listening to $mus"`
	fi
    fi
}

_screen() {
    max=`cat /sys/class/backlight/intel_backlight/max_brightness`
    actual=`cat /sys/class/backlight/intel_backlight/actual_brightness`
    screen=`echo $(( ($actual * 100) / $max ))`
    screen=`echo -e "\x05screen $screen%"`
}

_kbd() {
    max=`cat /sys/class/leds/smc::kbd_backlight/max_brightness`
    actual=`cat /sys/class/leds/smc::kbd_backlight/brightness`
    kbd=`echo $(( ($actual * 100) / $max ))`
    kbd=`echo -e "\x01keyboard $kbd%"`
}

status() {
    for arg in $@; do
	_${arg}
	args="${args}  `eval echo '$'$arg`"
    done
    echo "$args"
}

status kbd screen moc kernel uptime date heure volume bat
