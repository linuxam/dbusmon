#!/bin/bash

STATE_LOCK=0

dbus-monitor --system | 
    while read -r MESSAGE; do
        #echo "$MESSAGE"
        echo ">>>$([[ "$MESSAGE" =~ ^.*?\"(LockedHint)\"$ ]] && echo "${BASH_REMATCH[0]}")"
        if [[ $MESSAGE =~ ^.*\"LockedHint\"$ ]]
        then
            echo "Locked state changed"
            STATE_LOCK=1
        elif [[ $STATE_LOCK -eq 1 ]]
        then
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        echo "to locked"
                        STATE_LOCK=0
                    ;;
                    false)
                        echo "to unlocked"
                        STATE_LOCK=0
                    ;;
                esac
            fi
        fi

    done