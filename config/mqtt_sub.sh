#!/bin/bash

# This script subscribes to a MQTT topic using mosquitto_sub.
# On each message received, you can execute whatever you want.

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -u $MQTTUSER -P $MQTTPASSWORD -h $MQTTHOST -p $MQTTPORT -t $MQTTTOPIC/commands/# -I "VCONTROLD-SUB" -v | while read -r line;
    do
        topic=$(echo "$line" | cut -d' ' -f1)
        payload=$(echo "$line" | cut -d' ' -f2-)
        if [[ $topic =~ "/set" ]]; then
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
                vclient -h 127.0.0.1 -p 3002 -J -c "${command}" -o /etc/vcontrold/command_response.json
                result=$(cat /etc/vcontrold/command_response.json | jq -r '.[]')
                echo "Result: ${result}"
            fi
            # if the result of the command does begin with 'ERR' publish the result on $MQTTTOPIC/$payload
            if [[ "$rawresult" != ERR* ]];
            then
            # MQTT publish the result on $MQTTTOPIC/$payload

            mosquitto_pub -u $MQTTUSER -P $MQTTPASSWORD -h $MQTTHOST -p $MQTTPORT -t $MQTTTOPIC/$command -m "$result" -x 120 -c --id "VCONTROLD-PUB" -V "mqttv5"
            fi
        fi
    done
    sleep 10  # Wait 10 seconds until reconnection
done & # Discomment the & to run in background (but you should rather run THIS script in background)
