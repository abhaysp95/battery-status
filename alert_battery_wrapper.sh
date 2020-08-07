#!/usr/bin/env bash

# runs the alert_battery.sh script with a little sleep, this doesn't takes up the CPU

while true; do
	alert_battery.sh --stat
	sleep 1
done
