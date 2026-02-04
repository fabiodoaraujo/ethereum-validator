# ethereum-validator

This project will build from sources and install the necessary software for an Ethereum validator.

- An execution client: [Reth](https://reth.rs/)

- An consensus client: [Lighthouse](https://lighthouse-book.sigmaprime.io/)

***Note: This project does not yet create a new machine. For now, it only installs the necessary software on an existing Linux machine.***


|```provision.sh```       | build and install execution and consensus software |
|```start-validator.sh``` | start execution and consensus software |
|```check-health.sh```    | Validator Health check |


## Requeriments
Setup your environment in the config file ```configuration/config.sh```

An linux machine with ubuntu/debian

Recommended System Requirements:

CPU: Quad-core AMD Ryzen, Intel Broadwell, ARMv8 or newer

Memory: 32 GB RAM

Storage: 2 TB solid state drive

Network: 100 Mb/s download, 20 Mb/s upload broadband connection


### 1. Install the packages

Log in to the machine and run:

```sh
chmod +x provision.sh
./provision.sh 
```

#### 1.1. Generate key pairs

Withdrawal address

Your withdrawal address should be a regular Ethereum account that you control, Setting this address establishes your validator withdrawal credentials, and permanently links the chosen execution address to your validator. 

Follow the procedures described in this link:
https://hoodi.launchpad.ethereum.org/en/generate-keys

```sh
./deposit new-mnemonic --compounding --num_validators 1 --amount 32 --chain hoodi --withdrawal_address <YOUR_ETH_ADDRESS>
```

**You must secure your mnemonic phares**

### 1.2 Upload deposit data file.

The ```deposit_data-[timestamp].json``` file is located in the ```/ethstaker-deposit-cli/validator_keys``` directory that you created in the previous step.

Upload the deposit data file you just generated in this site:
https://hoodi.launchpad.ethereum.org/en/upload-deposit-data


### 1.2 Import validator keys

login back to the machine and run:

```sh
lighthouse --network hoodi account validator import \
    --directory /tmp/keys \
    --datadir /data/ethereum/hoodi/lighthouse \
    --network hoodi
```

### 2. Start Ethereum Consensus and Execution

```sh
chmod +x start-validator.sh 
./start-validator.sh 
```

### 3. Check status

After validator is active (this may take a few hours), you will be able to check the validator's status.

```sh
chmod +x check-health.sh
./check-health.sh
```

## todo
- Create scripts to start the validator using Docker. **Work in progress**
- Create Terraform code to provision the infrastructure in the cloud. **Work in progress**
- Create an Ansible code to install requirements and packages on the machine.

