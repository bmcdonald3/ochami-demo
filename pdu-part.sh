#!/bin/bash

run_and_wait() {
    local cmd_string="$1"
    echo ""
    read -p "${cmd_string}"
    eval "${cmd_string}"
}

set -e

echo "STEP 1: Scanning for PDUs on the network..."
run_and_wait "./magellan scan --subnet 10.254.1.0/17 -F json --include=pdus"


echo -e "\n STEP 2: Collecting inventory from PDU 'x3000m0'..."
run_and_wait "./magellan collect pdu x3000m0 --username admn --password admn -v"
