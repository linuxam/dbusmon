#!/bin/bash

STATE_LOCK=0
STATE_BATT=0

dbus-monitor --system | 
    while read -r MESSAGE
    do
        if [[ $MESSAGE =~ ^.*\"LockedHint\"$ ]]
        then
            STATE_LOCK=1
        elif [[ $STATE_LOCK -eq 1 ]]
        then
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        echo "Desktop is locked"
                        STATE_LOCK=0
                    ;;
                    false)
                        echo "Desktop is unlocked"
                        STATE_LOCK=0
                    ;;
                esac
            fi
        elif [[ "$MESSAGE" =~ ^.*?\"OnBattery\"$ ]]
        then
            STATE_BATT=1
        elif [[ $STATE_BATT -eq 1 ]]
        then
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        echo "Poer is disconneccted ($ICON_BATT)"
                        notify-send --urgency=normal --icon=$ICON_BATT --category=INFORMATION "Power disconnected"
                        STATE_BATT=0
                    ;;
                    false)
                        echo "Power is connected  ($ICON_BATT)"
                        notify-send --urgency=normal --icon=$ICON_BATT --category=INFORMATION "Power connected"
                        STATE_BATT=0
                    ;;
                esac
            fi
        elif [[ $MESSAGE =~ ^.*?\"(battery-.*?)\"$ ]]
        then
            ICON_BATT="${BASH_REMATCH[1]}"
        fi
    done