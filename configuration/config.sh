# --- CONFIGURATION ---
USER_NAME="ethereum"
BASE_PATH="/data/ethereum/"
NETWORK="hoodi"
SYNC_URL="https://hoodi.checkpoint.sigp.io"
JWT_PATH="$BASE_PATH/$NETWORK/jwt.hex"
RETH_DATA_DIR="$BASE_PATH/$NETWORK/reth"
RETH_LOG_PATH="$BASE_PATH/$NETWORK/reth/log"
LH_DATA_DIR="$BASE_PATH/$NETWORK/lighthouse"
LH_LOG_PATH="$BASE_PATH/$NETWORK/lighthouse/log"
BN_URL="http://127.0.0.1:5052"

FEE_RECIPIENT="0xYourEthAddressHere" #### <<<------ Replace with your eth Address
PUBKEY="abc123abc123abc123"          #### <<<------ Replace with your validator pubkey
