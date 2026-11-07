#!/bin/bash

# Home Assistant MQTT Discovery script for openv-vcontrold-docker
# Automatically creates entities and groups them under the "Zentralheizung" device.

DISCOVERY_PREFIX="${MQTT_DISCOVERY_PREFIX:-homeassistant}"
NODE_ID="vcontrold"

AUTH_ARGS=()
[ -n "$MQTTUSER" ] && AUTH_ARGS+=(-u "$MQTTUSER")
[ -n "$MQTTPASSWORD" ] && AUTH_ARGS+=(-P "$MQTTPASSWORD")

DEVICE='{
  "identifiers": ["vcontrold"],
  "name": "Zentralheizung",
  "model": "KO1B",
  "manufacturer": "Viessmann"
}'

pub() {
  local component="$1"
  local object_id="$2"
  local payload="$3"
  mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" \
    -t "${DISCOVERY_PREFIX}/${component}/${NODE_ID}/${object_id}/config" \
    -m "$payload" -r
}

echo "Publishing Home Assistant MQTT discovery configurations..."

# ======================== TEMPERATURE SENSORS ========================

pub "sensor" "getTempA" "{
  \"name\": \"Aussentemperatur\",
  \"unique_id\": \"vcontroldgetTempA\",
  \"state_topic\": \"${MQTTTOPIC}/getTempA\",
  \"value_template\": \"{{ value_json.value }}\",
  \"device_class\": \"temperature\",
  \"state_class\": \"measurement\",
  \"unit_of_measurement\": \"°C\",
  \"device\": ${DEVICE}
}"

pub "sensor" "getTempWWist" "{
  \"name\": \"Warmwassertemperatur\",
  \"unique_id\": \"vcontroldgetTempWWist\",
  \"state_topic\": \"${MQTTTOPIC}/getTempWWist\",
  \"value_template\": \"{{ value_json.value }}\",
  \"device_class\": \"temperature\",
  \"state_class\": \"measurement\",
  \"unit_of_measurement\": \"°C\",
  \"device\": ${DEVICE}
}"

pub "sensor" "getTempKist" "{
  \"name\": \"Kesseltemperatur\",
  \"unique_id\": \"vcontroldgetTempKist\",
  \"state_topic\": \"${MQTTTOPIC}/getTempKist\",
  \"value_template\": \"{{ value_json.value }}\",
  \"device_class\": \"temperature\",
  \"state_class\": \"measurement\",
  \"unit_of_measurement\": \"°C\",
  \"device\": ${DEVICE}
}"

pub "sensor" "getTempVListM1" "{
  \"name\": \"Vorlauftemperatur\",
  \"unique_id\": \"vcontroldgetTempVListM1\",
  \"state_topic\": \"${MQTTTOPIC}/getTempVListM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"device_class\": \"temperature\",
  \"state_class\": \"measurement\",
  \"unit_of_measurement\": \"°C\",
  \"device\": ${DEVICE}
}"

pub "sensor" "getTempStp" "{
  \"name\": \"Speichertemperatur\",
  \"unique_id\": \"vcontroldgetTempStp\",
  \"state_topic\": \"${MQTTTOPIC}/getTempStp\",
  \"value_template\": \"{{ value_json.value }}\",
  \"device_class\": \"temperature\",
  \"state_class\": \"measurement\",
  \"unit_of_measurement\": \"°C\",
  \"device\": ${DEVICE}
}"

# ======================== SWITCHES ========================

pub "switch" "getBetriebPartyM1" "{
  \"name\": \"Partybetrieb\",
  \"unique_id\": \"vcontroldgetBetriebPartyM1\",
  \"state_topic\": \"${MQTTTOPIC}/getBetriebPartyM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setBetriebPartyM1\",
  \"payload_on\": \"1\",
  \"payload_off\": \"0\",
  \"state_on\": \"1\",
  \"state_off\": \"0\",
  \"value_template\": \"{{ value_json.raw }}\",
  \"device\": ${DEVICE}
}"

pub "switch" "getBetriebSparM1" "{
  \"name\": \"Sparbetrieb\",
  \"unique_id\": \"vcontroldgetBetriebSparM1\",
  \"state_topic\": \"${MQTTTOPIC}/getBetriebSparM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setBetriebSparM1\",
  \"payload_on\": \"1\",
  \"payload_off\": \"0\",
  \"state_on\": \"1\",
  \"state_off\": \"0\",
  \"value_template\": \"{{ value_json.raw }}\",
  \"device\": ${DEVICE}
}"

# ======================== SELECT ========================

pub "select" "getBetriebArtM1" "{
  \"name\": \"Betriebsart\",
  \"unique_id\": \"vcontroldgetBetriebArtM1\",
  \"state_topic\": \"${MQTTTOPIC}/getBetriebArtM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setBetriebArtM1\",
  \"value_template\": \"{{ value_json.raw }}\",
  \"options\": [\"Abschalt\", \"NurWW\", \"Heizen+WW\"],
  \"device\": ${DEVICE}
}"

# ======================== NUMBERS (Heizkurve & Sollwerte) ========================

pub "number" "setNeigungM1" "{
  \"name\": \"Heizkurve Neigung M1\",
  \"unique_id\": \"vcontroldsetNeigungM1\",
  \"state_topic\": \"${MQTTTOPIC}/getNeigungM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setNeigungM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": 0.2,
  \"max\": 3.5,
  \"step\": 0.1,
  \"mode\": \"box\",
  \"device\": ${DEVICE}
}"

pub "number" "setNiveauM1" "{
  \"name\": \"Heizkurve Niveau M1\",
  \"unique_id\": \"vcontroldsetNiveauM1\",
  \"state_topic\": \"${MQTTTOPIC}/getNiveauM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setNiveauM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": -13,
  \"max\": 40,
  \"step\": 1,
  \"unit_of_measurement\": \"K\",
  \"mode\": \"box\",
  \"device\": ${DEVICE}
}"

pub "number" "setTempWWsoll" "{
  \"name\": \"Warmwassersolltemperatur\",
  \"unique_id\": \"vcontroldsetTempWWsoll\",
  \"state_topic\": \"${MQTTTOPIC}/getTempWWsoll\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setTempWWsoll\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": 10,
  \"max\": 60,
  \"step\": 1,
  \"unit_of_measurement\": \"°C\",
  \"mode\": \"slider\",
  \"device\": ${DEVICE}
}"

pub "number" "setTempRaumNorSollM1" "{
  \"name\": \"Raumsolltemperatur Normal M1\",
  \"unique_id\": \"vcontroldsetTempRaumNorSollM1\",
  \"state_topic\": \"${MQTTTOPIC}/getTempRaumNorSollM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setTempRaumNorSollM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": 10,
  \"max\": 30,
  \"step\": 1,
  \"unit_of_measurement\": \"°C\",
  \"mode\": \"slider\",
  \"device\": ${DEVICE}
}"

pub "number" "setTempPartyM1" "{
  \"name\": \"Partybetrieb Solltemperatur M1\",
  \"unique_id\": \"vcontroldsetTempPartyM1\",
  \"state_topic\": \"${MQTTTOPIC}/getTempPartyM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setTempPartyM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": 10,
  \"max\": 30,
  \"step\": 1,
  \"unit_of_measurement\": \"°C\",
  \"mode\": \"slider\",
  \"device\": ${DEVICE}
}"

pub "number" "setTempRaumRedSollM1" "{
  \"name\": \"Raumsolltemperatur Reduziert M1\",
  \"unique_id\": \"vcontroldsetTempRaumRedSollM1\",
  \"state_topic\": \"${MQTTTOPIC}/getTempRaumRedSollM1\",
  \"command_topic\": \"${MQTTTOPIC}/commands/setTempRaumRedSollM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"min\": 3,
  \"max\": 25,
  \"step\": 1,
  \"unit_of_measurement\": \"°C\",
  \"mode\": \"slider\",
  \"device\": ${DEVICE}
}"

# ======================== BINARY SENSORS / STATUS ========================

pub "binary_sensor" "getBrennerStatus" "{
  \"name\": \"Brenner aktiv\",
  \"unique_id\": \"vcontroldgetBrennerStatus\",
  \"state_topic\": \"${MQTTTOPIC}/getBrennerStatus\",
  \"value_template\": \"{{ 'ON' if (value_json.value | float(0) > 0) else 'OFF' }}\",
  \"device_class\": \"running\",
  \"device\": ${DEVICE}
}"

pub "binary_sensor" "getPumpeStatusZirku" "{
  \"name\": \"Zirkulationspumpe aktiv\",
  \"unique_id\": \"vcontroldgetPumpeStatusZirku\",
  \"state_topic\": \"${MQTTTOPIC}/getPumpeStatusZirku\",
  \"value_template\": \"{{ 'ON' if (value_json.value | float(0) > 0) else 'OFF' }}\",
  \"device_class\": \"running\",
  \"device\": ${DEVICE}
}"

pub "sensor" "getPumpeStatusM1" "{
  \"name\": \"Heizkreispumpe M1\",
  \"unique_id\": \"vcontroldgetPumpeStatusM1\",
  \"state_topic\": \"${MQTTTOPIC}/getPumpeStatusM1\",
  \"value_template\": \"{{ value_json.value }}\",
  \"unit_of_measurement\": \"%\",
  \"icon\": \"mdi:pump\",
  \"device\": ${DEVICE}
}"

# ======================== DAILY TIMERS (Mo - So: Start & Stop fields) ========================

DAYS=("Mo:Montag" "Di:Dienstag" "Mi:Mittwoch" "Do:Donnerstag" "Fr:Freitag" "Sa:Samstag" "So:Sonntag")
TYPES=("M1:Heizung:mdi:radiator" "WW:Warmwasser:mdi:water-boiler" "Zirku:Zirkulation:mdi:pump")
SLOTS=("start1:Start 1" "stop1:Ende 1" "start2:Start 2" "stop2:Ende 2")

# Clean up old text entities if present
for day_entry in "${DAYS[@]}"; do
  code="${day_entry%%:*}"
  for type_entry in "${TYPES[@]}"; do
    type_code="${type_entry%%:*}"
    mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" -r \
      -t "${DISCOVERY_PREFIX}/text/${NODE_ID}/setTimer${type_code}${code}/config" -m ""
  done
done

# Register individual time pickers
for day_entry in "${DAYS[@]}"; do
  code="${day_entry%%:*}"
  day_name="${day_entry##*:}"

  for type_entry in "${TYPES[@]}"; do
    IFS=":" read -r type_code type_name icon <<< "$type_entry"

    for slot_entry in "${SLOTS[@]}"; do
      IFS=":" read -r slot_code slot_name <<< "$slot_entry"

      pub "time" "${type_code}_${code}_${slot_code}" "{
        \"name\": \"${type_name} ${day_name} ${slot_name}\",
        \"unique_id\": \"vcontrold_${type_code}_${code}_${slot_code}\",
        \"command_topic\": \"${MQTTTOPIC}/commands/timer/${type_code}${code}/${slot_code}\",
        \"state_topic\": \"${MQTTTOPIC}/timer/${type_code}${code}/${slot_code}\",
        \"icon\": \"${icon}\",
        \"device\": ${DEVICE}
      }"
    done
  done
done

echo "Home Assistant discovery configurations published successfully."

# ======================== INITIAL TIMERS RETRIEVAL ========================
echo "Reading and publishing current schedule values..."
ALL_TIMERS="getTimerM1Mo,getTimerM1Di,getTimerM1Mi,getTimerM1Do,getTimerM1Fr,getTimerM1Sa,getTimerM1So,getTimerWWMo,getTimerWWDi,getTimerWWMi,getTimerWWDo,getTimerWWFr,getTimerWWSa,getTimerWWSo,getTimerZirkuMo,getTimerZirkuDi,getTimerZirkuMi,getTimerZirkuDo,getTimerZirkuFr,getTimerZirkuSa,getTimerZirkuSo"

mkdir -p /etc/vcontrold
echo "{" > /etc/vcontrold/timers.json
first=1

vclient -h 127.0.0.1:3002 -c "$ALL_TIMERS" 2>/dev/null | awk '
  /^getTimer/ {
    if (cmd != "") {
      print cmd "|" s1 "|" e1 "|" s2 "|" e2
    }
    cmd = substr($1, 9, length($1)-9)
    s1 = "00:00"; e1 = "00:00"; s2 = "00:00"; e2 = "00:00"
  }
  /^1:An:/ {
    if ($1 !~ /--/ && $2 !~ /--/) {
      s1 = substr($1, 6); e1 = substr($2, 5)
    }
  }
  /^2:An:/ {
    if ($1 !~ /--/ && $2 !~ /--/) {
      s2 = substr($1, 6); e2 = substr($2, 5)
    }
  }
  END {
    if (cmd != "") {
      print cmd "|" s1 "|" e1 "|" s2 "|" e2
    }
  }
' | while IFS="|" read -r key s1 e1 s2 e2; do
  [ -z "$key" ] && continue
  if [ $first -eq 1 ]; then
    first=0
  else
    echo "," >> /etc/vcontrold/timers.json
  fi
  printf '  "%s": ["%s", "%s", "%s", "%s"]' "$key" "$s1" "$e1" "$s2" "$e2" >> /etc/vcontrold/timers.json

  mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" -r -t "${MQTTTOPIC}/timer/${key}/start1" -m "${s1}:00"
  mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" -r -t "${MQTTTOPIC}/timer/${key}/stop1" -m "${e1}:00"
  mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" -r -t "${MQTTTOPIC}/timer/${key}/start2" -m "${s2}:00"
  mosquitto_pub "${AUTH_ARGS[@]}" -h "$MQTTHOST" -p "$MQTTPORT" -r -t "${MQTTTOPIC}/timer/${key}/stop2" -m "${e2}:00"
done
echo "" >> /etc/vcontrold/timers.json
echo "}" >> /etc/vcontrold/timers.json

echo "Initial schedules published to MQTT with retain."
