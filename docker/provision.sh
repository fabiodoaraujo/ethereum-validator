#!/bin/bash

echo "Provisioning Ethereum validator environment..."

# Check dependencies
command -v docker >/dev/null 2>&1 || { echo "Docker is required"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is required"; exit 1; }

# Create persistent directories
mkdir -p /data/ethereum/hoodi/reth /data/ethereum/hoodi/lighthouse

# Load env
if [ ! -f .env ]; then
  cp .env.example .env
  echo ".env created. Please set TESTNET and FEE_RECIPIENT."
fi

# # Generate validator keys if missing
# if [ ! -d /data/ethereum/hoodi/lighthouse ]; then
#   docker run --rm -it \
#     -v $(pwd)/data/consensus:/keys \
#     sigp/lighthouse:latest \
#     lighthouse account validator import \
#       --network hoodi \
#       --keystore /tmp/keys/ \
#       --password-file /tmp/keys/password.txt \
#       --reuse-password
# fi

echo "Provisioning complete"
