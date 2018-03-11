#!/bin/bash

STATE_LOCK=0
STATE_BATT=0

dbus-monitor --system | 
    while read -r MESSAGE
    do
        if [[ $MESSAGE =~ ^.*\"LockedHint\"$ ]]
        then
            echo "Desktop is"
            STATE_LOCK=1
        elif [[ $STATE_LOCK -eq 1 ]]
        then
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        echo "  locked"
                        STATE_LOCK=0
                    ;;
                    false)
                        echo "  unlocked"
                        STATE_LOCK=0
                    ;;
                esac
            fi
        elif [[ "$MESSAGE" =~ ^.*?\"OnBattery\"$ ]]
        then
            echo "Power is"
            STATE_BATT=1
        elif [[ $STATE_BATT -eq 1 ]]
        then
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        echo "  disconneccted"
                        STATE_BATT=0
                    ;;
                    false)
                        echo "  connected"
                        STATE_BATT=0
                    ;;
                esac
            fi
        fi
    done