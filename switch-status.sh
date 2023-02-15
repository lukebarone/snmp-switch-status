#!/bin/bash
# Uses the config to run snmpget and pull the data

LEVEL="authPriv"
# Requires a common USERNAME, AUTH_PASS, ENC_KEY. Read from the .env file in
# the same directory
. .env

# Colours for the output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

while IFS=' ' read -r ip auth priv low high name; do
    IP="${ip}"
    AUTH_METHOD="${auth}"
    PRIV_METHOD="${priv}"
    SWITCH_NAME="${name}"
    TMP_FILE=$(mktemp)

    eval snmpget -v3 -l "${LEVEL}" -u "${USERNAME}" -a "${AUTH_METHOD}" \
        -A "${AUTH_PASS}" -x "${PRIV_METHOD}" -X "${ENC_KEY}" -OqU "${IP}:161" \
        1.3.6.1.2.1.2.2.1.8.\{"${low}".."${high}"\} | cut -f2 -d' ' > $TMP_FILE
    eval snmpget -v3 -l "${LEVEL}" -u "${USERNAME}" -a "${AUTH_METHOD}" \
        -A "${AUTH_PASS}" -x "${PRIV_METHOD}" -X "${ENC_KEY}" -OqU "${IP}:161" \
        1.3.6.1.2.1.2.2.1.5.\{"${low}".."${high}"\} | cut -f2 -d' '> $TMP_FILE.speed

    echo -en "${YELLOW}${SWITCH_NAME} "
    COUNT=0
    while IFS=$'\t' read -r port speed; do
        if [[ "${port}" == "2" ]]; then
            echo -en "${RED}o"
        else
            if (( speed > 100000000 )) || (( speed == 1000 )); then
                color="${GREEN}"
            else
                color="${YELLOW}"
            fi
            echo -en "${color}•"
            ((COUNT=COUNT+1))
        fi
    done < <(paste "$TMP_FILE" "$TMP_FILE.speed")
    echo -en "${YELLOW} ${COUNT} in use"
    echo -en "\n"
done < switches.conf
echo -e "${NC}"
