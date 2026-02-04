#!/bin/bash

# Author: Fabio Sales
# Objective: bring the validator and execution layer online.

# List services in order of startup dependency
SERVICES=("reth" "lh_bn" "lh_vc")

# Function to start a single service and check its status
start_service() {
    local SERVICE_NAME=$1
    echo "--- Attempting to start: $SERVICE_NAME ---"
    
    if sudo systemctl start "$SERVICE_NAME"; then
        # Wait a moment for the service to actually initialize
        sleep 10
        
        # Check if the service is active
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo "[SUCCESS] $SERVICE_NAME is running."
        else
            echo "[ERROR] $SERVICE_NAME failed to stay active. Check 'journalctl -u $SERVICE_NAME -f'"
            return 1
        fi
    else
        echo "[FAILED] Command 'systemctl start $SERVICE_NAME' failed."
        return 1
    fi
}

# Main function to start all node components
start_node() {
    echo "=========================================="
    echo "   Ethereum Node Startup Sequence         "
    echo "=========================================="

    for service in "${SERVICES[@]}"; do
        if ! start_service "$service"; then
            echo "Critical failure starting $service. Aborting sequence."
            exit 1
        fi
    done

    echo "=========================================="
    echo "   All services started successfully!     "
    echo "=========================================="
}

# Execution
start_node