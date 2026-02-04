#!/bin/bash

# Author: Fabio Sales
# Objective: Install validator and execution layer software and dependencies.

# Load external config
source ./configuration/config.sh

# Install Git on Ubuntu/Debian systems
install_git() {
    echo "######################################"
    echo "        Checking for Git...           "
    echo "######################################"

    if command -v git &> /dev/null; then
        echo "Git is already installed: $(git --version)"
    else
        echo "Git not found. Updating package lists and installing..."
                
        # Install git
        sudo apt update
        sudo apt install -y git
        
        if [ $? -eq 0 ]; then
            echo "Git installed successfully!"
            git --version
        else
            echo "Error: Git installation failed."
            return 1
        fi
    fi
}

# Install Rust on Ubuntu/Debian systems
install_rust() {
    echo "######################################"
    echo "    Checking for Rust installation    "
    echo "######################################"

    echo "------------------------"
    echo "Install system utilities"
    echo "------------------------"
    sudo apt update
    sudo apt install -y \
        curl \
        jq \
        tar \
        gcc \
        g++ \
        make \
        cmake \
        libclang-dev \
        clang \
        llvm-dev \
        pkg-config \
        build-essential \
        libssl-dev

    # Check if rustc is already in the PATH
    if command -v rustc &> /dev/null; then
        echo "Rust is already installed: $(rustc --version)"
    else
        echo "Rust not found. Starting installation..."

        # Download the rustup installer and run it non-interactively
        # -sSf: silent/show error/fail on server errors
        # -y: skip the interactive prompt and use defaults
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        # Source the cargo env file to use rustc immediately in the current shell
        source "$HOME/.cargo/env"

        echo "Rust installation completed successfully."
        echo "Version: $(rustc --version)"
    fi
}

# Install Reth on Ubuntu/Debian systems  
# https://reth.rs/installation/source
install_reth() {
    echo "######################################"
    echo "     Starting Reth Installation       "
    echo "         Ethereum Execution           "
    echo "######################################"

    # Create a directory for the source code
    mkdir -p ~/git && cd ~/git
    rm -rf reth
    git clone https://github.com/paradigmxyz/reth.git
    cd reth

    # Checkout the latest stable tag
    LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
    git checkout $LATEST_TAG
    echo "Building Reth version: $LATEST_TAG (this may take 10-20 minutes)..."

    # Build for release with jemalloc for better memory management
    cargo build --release
    sudo cp target/release/reth /usr/local/bin/reth

    echo "--- Reth Installation Complete! ---"
    /usr/local/bin/reth --version
}

# Install Lighthouse on Ubuntu/Debian systems
# https://lighthouse-book.sigmaprime.io/installation_source.html
install_lighthouse() {
    echo "######################################"
    echo "   Starting Lighthouse Source Build   "
    echo "        Ethereum Consensus            "
    echo "######################################"

    echo "Cloning Lighthouse repository..."
    mkdir -p ~/git && cd ~/git
    rm -rf lighthouse
    git clone https://github.com/sigp/lighthouse.git
    cd lighthouse
    
    echo "Checking out stable branch and compiling..."
    git checkout stable
    make

    echo "--- Lighthouse Installation Complete! ---"
    sudo cp target/release/lighthouse /usr/local/bin/lighthouse
    /usr/local/bin/lighthouse --version
}

check_version() {
    echo "######################################"
    echo "   Versions "
    echo "######################################"

    git --version
    rustc --version
    /usr/local/bin/reth --version
    /usr/local/bin/lighthouse --version
}

create_user() {
    echo "######################################"
    echo "    Creating ethereum user.           "
    echo "######################################"    
    sudo groupadd -f -g 6000 $USER_NAME
    sudo useradd -u 6000 -g $USER_NAME $USER_NAME
}

setup_directories() {
    echo "######################################"
    echo "Creating directories and JWT..."
    echo "######################################"
    sudo mkdir -p $BASE_PATH
    sudo mkdir -p $RETH_DATA_DIR
    sudo mkdir -p $LH_DATA_DIR
    
    if [ ! -f "$JWT_PATH" ]; then
        openssl rand -hex 32 | sudo tee $JWT_PATH > /dev/null
    fi
    
    sudo chown -R $USER_NAME:$USER_NAME $BASE_PATH $RETH_DATA_DIR $LH_DATA_DIR
    sudo chmod 600 $JWT_PATH
}

create_reth_service() {
    echo "######################################"
    echo "Creating Reth systemd service..."
    echo "######################################"

    sudo bash -c "cat > /etc/systemd/system/reth.service <<EOF
[Unit]
Description=Reth Execution Client
After=network.target

[Service]
User=$USER_NAME
Group=$USER_NAME
Environment=RUST_LOG=info
Type=simple
ExecStart=/usr/local/bin/reth node \\
    --chain $NETWORK \\
    --http \\
    --http.addr 0.0.0.0 \\
    --http.port 8545 \\
    --http.api eth,net,web3 \\
    --datadir $RETH_DATA_DIR \\
    --authrpc.addr 127.0.0.1 \\
    --authrpc.port 8551 \\
    --authrpc.jwtsecret $JWT_PATH \\
    --metrics 127.0.0.1:9001 \\
    --log.file.directory $RETH_LOG_PATH\\
    --full
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl daemon-reload
}

create_lh_bn_service() {
    echo "######################################"
    echo "Creating Lighthouse Beacon Node systemd service..."
    echo "######################################"

    sudo bash -c "cat > /etc/systemd/system/lh_bn.service <<EOF
[Unit]
Description=Lighthouse Beacon Node
After=network.target reth.service

[Service]
User=$USER_NAME
Group=$USER_NAME
Type=simple
ExecStart=/usr/local/bin/lighthouse bn \\
    --network $NETWORK \\
    --logfile-debug-level info \\
    --execution-endpoint http://127.0.0.1:8551 \\
    --execution-jwt $JWT_PATH \\
    --checkpoint-sync-url $SYNC_URL \\
    --http \\
    --logfile-dir $LH_LOG_PATH \\
    --datadir $LH_DATA_DIR
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl daemon-reload
}

create_lh_vc_service() {
    echo "######################################"
    echo "Creating Lighthouse Validator Client systemd service..."
    echo "######################################"

    sudo bash -c "cat > /etc/systemd/system/lh_vc.service <<EOF
[Unit]
Description=Lighthouse Validator Client
After=network.target lh_bn.service

[Service]
User=$USER_NAME
Group=$USER_NAME
Type=simple
ExecStart=/usr/local/bin/lighthouse vc \\
    --network $NETWORK \\
    --suggested-fee-recipient $FEE_RECIPIENT \\
    --logfile-dir $LH_LOG_PATH \\
    --datadir $LH_DATA_DIR
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl daemon-reload
}

# Main
install_git
install_rust
install_reth
install_lighthouse
check_version
create_user
setup_directories
create_reth_service
create_lh_bn_service
create_lh_vc_service

echo "######################################"
echo "   Services installed and created.    "
echo "######################################"

