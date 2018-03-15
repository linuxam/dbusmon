#!/bin/bash
#******************************************************************************
# DESCRIPTION:                                                                # 
# This script monitors dbus and watches for:                                  #
# * desktop lock/unlock events                                                #
# * power connect/disconnect events                                           #
# Put the commands, you would like to execute on certain event inside the     #
# correct case statement (see the comments).                                  #
#                                                                             #
# USAGE:                                                                      #
# I run it at my user's logon (startup applications)                          #
#                                                                             #
# SOURCE:                                                                     #
# https://github.com/user-resu/dbusmon                                        #
#******************************************************************************

sleep 10

STATE_LOCK=0
STATE_BATT=0

dbus-monitor --system | 
    while read -r MESSAGE
    do
        # Catch screen lock changes
        if [[ $MESSAGE =~ ^.*\"LockedHint\"$ ]]
        then
            # When detected, set $STATE_LOCK to 1 (so we know we are looking for first line with "...boolean tru/false")
            STATE_LOCK=1
        elif [[ $STATE_LOCK -eq 1 ]]
        then
            # Check if system is locked or unlocked (only when $STATE_LOCK equals 1)
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        # Desktop is locked...
                        # commands to execute when locked go bellow...
                        # ... check if keepass2 is running and lock all opened DBs ...
                        if [[ $(pgrep -f KeePass.exe) -gt 0 ]]
                        then
                            keepass2 --lock-all
                        fi
                        # Reset $STATE_LOCK back to 0 after executing all commands
                        STATE_LOCK=0
                    ;;
                    false)
                        #Desktop is unlocked
                        # commands to execute when unlocked go bellow...
                        
                        # Reset $STATE_LOCK back to 0 after executing all commands
                        STATE_LOCK=0
                    ;;
                esac
            fi
        # Catch power connection changes
        elif [[ "$MESSAGE" =~ ^.*?\"OnBattery\"$ ]]
        then
            # When detected, set $STATE_BATT to 1 (so we know we are looking for first line with "...boolean tru/false")
            STATE_BATT=1
        elif [[ $STATE_BATT -eq 1 ]]
        then
            # Check if system is on battery (only when $STATE_BATT equals 1)
            if [[ $MESSAGE =~ ^.*?boolean[[:space:]](.*?)$ ]]
            then
                case "${BASH_REMATCH[1]}" in
                    true)
                        # System is on battery
                        # commands to execute when power disconected go bellow...
                        # ... create desktop notification with appropriate icon
                        notify-send --urgency=normal --icon=$ICON_BATT --category=INFORMATION "Power disconnected"
                        # commands to execute when power disconected go abowe...
                        # Reset $STATE_BATT bask to 0 after executing all commands
                        STATE_BATT=0
                    ;;
                    false)
                        # System is on external power
                        # commands to execute when power connected go bellow...
                        # ... create desktop notification with appropriate icon ...
                        notify-send --urgency=normal --icon=$ICON_BATT --category=INFORMATION "Power connected"
                        # commands to execute when power connected go abowe...
                        # Reset $STATE_BATT bask to 0 after executing all commands
                        STATE_BATT=0
                    ;;
                esac
            fi
        # get the current battery icon in use (e.g. to be used in desktop notifications)
        elif [[ $MESSAGE =~ ^.*?\"(battery-.*?)\"$ ]]
        then
            ICON_BATT="${BASH_REMATCH[1]}"
        fi
    done