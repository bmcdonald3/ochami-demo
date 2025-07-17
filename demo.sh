#!/bin/bash

run_and_wait() {
    local cmd_string="$1"
    echo ""
    read -p "${cmd_string}"
    eval "${cmd_string}"
}

set -e

GAMORA_HOST="root@gamora-ncn-m001.hpc.amslabs.hpecorp.net"
REMOTE_PDU_FILE_PATH="/root/mcdonald/pdu-inventory.txt"
LOCAL_PDU_FILE="pdu-inventory.json"

BMC_IP="172.24.0.2"
BMC_USER="root"
BMC_PASS="initial0"
BMC_XNAME="x1000c1s7b0"

PDU_XNAME="x3000m0"
PDU_OUTLET_XNAME="x3000m0p0v17"

echo "STEP 1: Starting OpenCHAMI services..."
bash stop.sh
bash run.sh
echo "Services are up."

docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x3000m0 username=admn password=admn'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b0 username=root password=initial0'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b1 username=root password=initial0'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b2 username=root password=initial0'
sleep 5


echo "\n STEP 2: Collecting PDU inventory from remote system..."
run_and_wait "scp \"${GAMORA_HOST}:${REMOTE_PDU_FILE_PATH}\" \"./${LOCAL_PDU_FILE}\""

echo "\n STEP 3: Loading PDU inventory into SMD..."
run_and_wait "cat \"./${LOCAL_PDU_FILE}\" | magellan send http://localhost:27779"
run_and_wait "curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq"
run_and_wait "curl -sS \"http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints\" | jq"

echo "\n STEP 4: Collecting local BMC inventory..."
run_and_wait "magellan collect \"https://${BMC_IP}\" --username \"${BMC_USER}\" --password \"${BMC_PASS}\" -v | magellan send http://localhost:27779"

echo "\n STEP 5: Verifying that both BMCs and PDUs are in SMD..."
run_and_wait "curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq"
run_and_wait "curl -sS \"http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints\" | jq"

echo "\n STEP 6: Querying power status with PCS..."
echo "  - Querying BMC (${BMC_XNAME}n0):"
run_and_wait "curl -sS -X GET http://localhost:28007/v1/power-status?xname=${BMC_XNAME}n0 | jq '.'"
echo "  - Querying PDU Outlet (${PDU_OUTLET_XNAME}):"
run_and_wait "curl -sS -X GET http://localhost:28007/v1/power-status?xname=${PDU_OUTLET_XNAME} | jq '.'"

echo "\n STEP 7: Demonstrating power control on a BMC..."
echo "  - Sending 'Off' command to ${BMC_XNAME}n0..."
cmd_to_run="curl -sSi -X POST -H \"Content-Type: application/json\" -d '{\"operation\": \"Off\", \"location\": [{\"xname\": \"${BMC_XNAME}n0\"}]}' http://localhost:28007/v1/transitions | grep -i 'Location:' | awk -F'/' '{print \$NF}' | tr -d '\r'"
read -p "Press [enter] to run: ${cmd_to_run}"
TRANSITION_ID=$(eval "${cmd_to_run}")
echo "  - Transition ID: ${TRANSITION_ID}"

read -p "Let's wait a bit for the transition to complete..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/transitions/${TRANSITION_ID} | jq '.'"


echo "\n STEP 8: Powering the node back on..."
echo "  - Sending 'On' command to ${BMC_XNAME}n0..."
cmd_to_run_on="curl -sSi -X POST -H \"Content-Type: application/json\" -d '{\"operation\": \"On\", \"location\": [{\"xname\": \"${BMC_XNAME}n0\"}]}' http://localhost:28007/v1/transitions | grep -i 'Location:' | awk -F'/' '{print \$NF}' | tr -d '\r'"
read -p "Press [enter] to run: ${cmd_to_run_on}"
TRANSITION_ID_ON=$(eval "${cmd_to_run_on}")
echo "  - Transition ID: ${TRANSITION_ID_ON}"

read -p "Let's wait a bit for the transition to complete..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/transitions/${TRANSITION_ID_ON} | jq '.'"

echo "  - Verifying final power state..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/power-status?xname=${BMC_XNAME}n0 | jq '.'"


echo "\n STEP 9: Demonstrating power control on a PDU Outlet..."
echo "  - Sending 'Off' command to ${PDU_OUTLET_XNAME}..."
cmd_pdu_off="curl -sSi -X POST -H \"Content-Type: application/json\" -d '{\"operation\": \"Off\", \"location\": [{\"xname\": \"${PDU_OUTLET_XNAME}\"}]}' http://localhost:28007/v1/transitions | grep -i 'Location:' | awk -F'/' '{print \$NF}' | tr -d '\r'"
read -p "Press [enter] to run: ${cmd_pdu_off}"
TRANSITION_ID_PDU_OFF=$(eval "${cmd_pdu_off}")
echo "  - Transition ID: ${TRANSITION_ID_PDU_OFF}"

read -p "Let's wait a bit for the transition to complete..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/transitions/${TRANSITION_ID_PDU_OFF} | jq '.'"


echo "\n STEP 10: Powering the PDU Outlet back on..."
echo "  - Sending 'On' command to ${PDU_OUTLET_XNAME}..."
cmd_pdu_on="curl -sSi -X POST -H \"Content-Type: application/json\" -d '{\"operation\": \"On\", \"location\": [{\"xname\": \"${PDU_OUTLET_XNAME}\"}]}' http://localhost:28007/v1/transitions | grep -i 'Location:' | awk -F'/' '{print \$NF}' | tr -d '\r'"
read -p "Press [enter] to run: ${cmd_pdu_on}"
TRANSITION_ID_PDU_ON=$(eval "${cmd_pdu_on}")
echo "  - Transition ID: ${TRANSITION_ID_PDU_ON}"

read -p "Let's wait a bit for the transition to complete..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/transitions/${TRANSITION_ID_PDU_ON} | jq '.'"

echo "  - Verifying final power state..."
run_and_wait "curl -sS -X GET http://localhost:28007/v1/power-status?xname=${PDU_OUTLET_XNAME} | jq '.'"
