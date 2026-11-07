#!/bin/bash

# This script subscribes to a MQTT topic using mosquitto_sub.
# On each message received, you can execute whatever you want.

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -u $MQTTUSER -P $MQTTPASSWORD -h $MQTTHOST -p $MQTTPORT -t $MQTTTOPIC/commands/# -I "VCONTROLD-SUB" -v | while read -r line;
    do
        topic=$(echo "$line" | cut -d' ' -f1)
        payload=$(echo "$line" | cut -d' ' -f2-)
        # 1) Individual Time Picker commands: heizung/commands/timer/<key>/<slot>
        if [[ $topic =~ /commands/timer/([^/]+)/([^/]+) ]]; then
            key="${BASH_REMATCH[1]}"   # e.g. M1Mo, WWMo, ZirkuMo
            slot="${BASH_REMATCH[2]}"  # start1, stop1, start2, stop2
            new_time=$(echo "$payload" | grep -oE '[0-2][0-9]:[0-5][0-9]')
            [ -z "$new_time" ] && new_time="00:00"
            echo "Timer slot update: key=$key, slot=$slot, new_time=$new_time"

            case "$slot" in
                start1) idx=0 ;;
                stop1)  idx=1 ;;
                start2) idx=2 ;;
                stop2)  idx=3 ;;
            esac

            if [ -f /etc/vcontrold/timers.json ]; then
                jq --arg key "$key" --argjson idx "$idx" --arg val "$new_time" \
                   '.[$key][$idx] = $val' /etc/vcontrold/timers.json > /etc/vcontrold/timers.tmp && \
                   mv /etc/vcontrold/timers.tmp /etc/vcontrold/timers.json

                t0=$(jq -r --arg key "$key" '.[$key][0]' /etc/vcontrold/timers.json)
                t1=$(jq -r --arg key "$key" '.[$key][1]' /etc/vcontrold/timers.json)
                t2=$(jq -r --arg key "$key" '.[$key][2]' /etc/vcontrold/timers.json)
                t3=$(jq -r --arg key "$key" '.[$key][3]' /etc/vcontrold/timers.json)

                if [ "$t2" = "$t3" ] && [ "$t2" = "00:00" ]; then
                    cmd_payload="${t0} ${t1} - -"
                else
                    cmd_payload="${t0} ${t1} ${t2} ${t3}"
                fi

                echo "Applying schedule: setTimer${key} ${cmd_payload}"
                vclient -h 127.0.0.1 -p 3002 -J -c "setTimer${key} ${cmd_payload}" -o /etc/vcontrold/command_result.json
                rawresult=$(cat /etc/vcontrold/command_result.json | jq -r '.[].raw' 2>/dev/null)
                if [ "$rawresult" = "OK" ]; then
                    echo "Timer $key updated successfully."
                    mosquitto_pub -u "$MQTTUSER" -P "$MQTTPASSWORD" -h "$MQTTHOST" -p "$MQTTPORT" \
                      -t "$MQTTTOPIC/timer/${key}/${slot}" -m "${new_time}:00" -r
                else
                    echo "Failed to set timer $key: $rawresult"
                fi
            fi

        # 2) Standard set commands: heizung/commands/set*
        elif [[ $topic =~ "/set" ]]; then
            command=$(echo "$topic" | awk -F'/' '{print $NF}')
            echo "Command: $command and payload $payload"
            vclient -h 127.0.0.1 -p 3002 -J -c "${command} ${payload}" -o /etc/vcontrold/command_result.json
            result=$(cat /etc/vcontrold/command_result.json | jq -r '.[]')
            echo "Result: ${result}"
            # if the result of the command is 'OK' and the first 3 char of the payload was 'set' remove the 'set' and add 'get' instead and run the vclient with it as command
            # also remove everything after the first space in the payload
            rawresult=$(cat /etc/vcontrold/command_result.json | jq -r '.[].raw')
            if [ "$rawresult" == "OK" ]; then
                echo "OK received, run get command"
                command=${command:3}
                command=${command%% *}
                command="get${command}"
                echo "New payload: ${command}"
                if [[ "$command" == getTimer* ]]; then
                    times=$(vclient -h 127.0.0.1 -p 3002 -c "${command}" | grep -oE '[0-2][0-9]:[0-5][0-9]' | tr '\n' ' ' | sed 's/ $//')
                    [ -z "$times" ] && times="--:--"
                    result="$times"
                else
                    vclient -h 127.0.0.1 -p 3002 -J -c "${command}" -o /etc/vcontrold/command_response.json
                    result=$(cat /etc/vcontrold/command_response.json | jq -r '.[]' 2>/dev/null)
                fi
                echo "Result: ${result}"
            fi
            # if the result of the command does begin with 'ERR' publish the result on $MQTTTOPIC/$payload
            if [[ "$rawresult" != ERR* ]];
            then
            # MQTT publish the result on $MQTTTOPIC/$payload

            mosquitto_pub -u $MQTTUSER -P $MQTTPASSWORD -h $MQTTHOST -p $MQTTPORT -t $MQTTTOPIC/$command -m "$result" -r -c --id "VCONTROLD-PUB" -V "mqttv5"
            fi
        fi
    done
    sleep 10  # Wait 10 seconds until reconnection
done & # Discomment the & to run in background (but you should rather run THIS script in background)
