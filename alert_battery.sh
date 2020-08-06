#!/usr/bin/env bash

bsfile="$HOME/.cache/temp/bsfile"
if [ ! -f "${bsfile}" ]; then
	touch "$bsfile"
	echo "0 Charged" > "${bsfile}"
fi

function get_help() {
	printf "Usage:\talert_battery.sh [Option]\n\n"
	printf "\tSupported Options:\n"
	printf "\t\t--stat:\tGives notification of Charging, Discharging,\n"
	printf "\t\t\t\tCharged and Low battery\n"
	printf "\t\t--help:\tShow this help menu\n\n"
	printf "Note:\n1. Provide no option runs the script to show only Low Battery Status\n"
	printf "2. Running the script with cron and/or some type of auto-startup uitility is recommended\n"
	printf "3. Requires some notification-daemon already running in system\n"
}

function general_status() {
	local flag=$(cat "${bsfile}" | cut -d' ' -f 2)
	if [ "${status_bat}" != "${flag}" ]; then
		echo "0 ${status_bat}" > "${bsfile}"
		if [ ${status_bat} = "Discharging" ]; then
			# echo "Battery is now Discharging"
			notify-send -t 7500 -i "$HOME/.cache/notify-icons/battery_disconnected.png" "Battery is now ${status_bat}" "Current level: ${capacity}"
		elif [ "${status_bat}" = "Charging" ]; then
			# echo "Battery is now Charging"
			notify-send -t 7500 -i "$HOME/.cache/notify-icons/battery_charging.png" "Battery is now ${status_bat}" "Current level: ${capacity}"
		elif [ "${status_bat}" = "Charged" ]; then
			# echo "Battery is ${status_bat}"
			notify-send -t 7500 -i "$HOME/.cache/notify-icons/battery_charging.png" "Battery is fully ${status_bat}" "Current level: ${capacity}"
		fi
	fi
}

function critical_status() {
	if [ "${capacity}" -le 30 ] && [ "${status_bat}" = "Discharging" ]; then
		# replace notification with charging one, so that sleep doesn't effect it's showing
		notify-send --urgency=critical -t 10000 -i "$HOME/.cache/notify-icons/battery_low.png" "Battery level, Please plug the charger" "Current Battery-level: ${capacity}%"
		count=$(cat "${bsfile}" | cut -d' ' -f 1)
		while true; do
			if [ "${status_bat}" != "Charging" ]; then
				count=$(( count + 1 ))
				echo "${count} ${status_bat}" > "${bsfile}"
				if [ "${count}" -eq 59 ]; then
					echo "0 ${status_bat}" > "${bsfile}"
					break
				fi
				sleep 1
			fi
		done
	fi
}

for battery in /sys/class/power_supply/BAT?; do
	capacity=$(cat "${battery}"/capacity)
	status_bat=$(cat "${battery}"/status)

	case "$1" in
		--help)
			get_help
			exit 0 ;;
		--stat)
			general_status
			critical_status
			exit 0 ;;
		*)
			critical_status
			exit 0 ;;
	esac


done
