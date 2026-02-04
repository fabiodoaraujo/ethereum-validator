#!/bin/bash

# Author: Fabio Sales
# Objective: verify validator readiness via an API endpoint.

# Load external config
source ./configuration/config.sh

# Fetch Validator Status
# Returns status like "active_ongoing", "pending_queued", etc.
STATUS_DATA=$(curl -s "$BN_URL/eth/v1/beacon/states/head/validators/$PUBKEY")
STATUS=$(echo "$STATUS_DATA" | jq -r '.data.status')

# Fetch Current Network Slot
SLOT_DATA=$(curl -s "$BN_URL/eth/v1/beacon/headers")
SLOT=$(echo "$SLOT_DATA" | jq -r '.data[0].header.message.slot')

# Generate Human-Readable Output
if [ "$STATUS" == "active_ongoing" ]; then
    echo "validator \"$PUBKEY\" is active and attesting on slot $SLOT"
else
    echo "validator \"$PUBKEY\" is NOT active (Status: $STATUS) at slot $SLOT"
fi