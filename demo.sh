#!/bin/bash

set -e

GAMORA_HOST="root@gamora-ncn-m001.hpc.amslabs.hpecorp.net"
REMOTE_PDU_FILE_PATH="/root/mcdonald/pdu-inventory.txt"
LOCAL_PDU_FILE="pdu-inventory.json"

BMC_IP="172.24.0.2"
BMC_USER="root"
BMC_PASS="initial0"
BMC_XNAME="x1000c1s7b0"

PDU_XNAME="x3000m0"
PDU_OUTLET_XNAME="x3000m0p0v1"

echo "STEP 1: Starting OpenCHAMI services..."
bash stop.sh
bash run.sh
echo "Services are up."

docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x3000m0 username=admn password=admn'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b0 username=root password=initial0'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b1 username=root password=initial0'
docker exec -e VAULT_TOKEN=hms -e VAULT_ADDR=http://localhost:8200 vault sh -c 'vault kv put secret/hms-creds/x1000c1s7b2 username=root password=initial0'
sleep 5
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 2: Collecting PDU inventory from remote system..."
scp "${GAMORA_HOST}:${REMOTE_PDU_FILE_PATH}" "./${LOCAL_PDU_FILE}"
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 3: Loading PDU inventory into SMD..."
cat "./${LOCAL_PDU_FILE}" | magellan send http://localhost:27779
curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq
read -p "Press [Enter] to continue..."
curl -sS "http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints" | jq
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 4: Collecting local BMC inventory..."
magellan collect "https://${BMC_IP}" --username "${BMC_USER}" --password "${BMC_PASS}" -v | magellan send http://localhost:27779
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 5: Verifying that both BMCs and PDUs are in SMD..."
curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq
read -p "Press [Enter] to continue..."
curl -sS "http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints" | jq
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 6: Querying power status with PCS..."
echo "  - Querying BMC (${BMC_XNAME}n0):"
curl -sS -X GET http://localhost:28007/v1/power-status?xname=${BMC_XNAME}n0 | jq '.'
echo "  - Querying PDU Outlet (${PDU_OUTLET_XNAME}):"
curl -sS -X GET http://localhost:28007/v1/power-status?xname=${PDU_OUTLET_XNAME} | jq '.'
read -p "Press [Enter] to continue..."

echo "\n🚀 STEP 7: Demonstrating power control on a BMC..."
echo "  - Sending 'Off' command to ${BMC_XNAME}n0..."
TRANSITION_ID=$(curl -sS -X POST -H "Content-Type: application/json" -d "{\"operation\": \"Off\", \"location\": [{\"xname\": \"${BMC_XNAME}n0\"}]}" http://localhost:28007/v1/transitions | jq -r '.transition_id')
echo "  - Transition ID: ${TRANSITION_ID}"
sleep 2
curl -sS -X GET http://localhost:28007/v1/transitions/${TRANSITION_ID} | jq '.'
