<!-- Need to review this readme before pushing to github! -->

# Foundry Fund Me

## Description

A crowd funding smart contract as part of the [Cyfrin Foundry Course](https://github.com/Cyfrin/foundry-full-course-cu)

## Table of Contents

- [Installation](#installation)
  - [Required](#required)
  - [Optional](#optional)
- [Usage](#usage)
  - [Getting Started](#getting-started)
  - [Deploy](#deploy)
  - [Testing](#testing)
  - [Test Coverage](#test-coverage)
  - [Local zkSync](#local-zksync)
    - [(Additional) Requirements](#additional-requirements)
    - [Setup local zkSync node](#setup-local-zksync-node)
    - [Deploy to local zkSync node](#deploy-to-local-zksync-node)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
  - [Withdraw](#withdraw)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)

# Installation

## Required

**Foundry**

- Follow the instructions on [getfoundry](https://book.getfoundry.sh/getting-started/installation) to install Foundry on your local machine

## Optional

1. **Foundry zksync**

- If you want to deploy your contract to zksync, follow the instructions on [foundry zksync](https://foundry-book.zksync.io/getting-started/installation) to install Foundry zksync on your local machine

2. **Docker**

- To work with Foundry zksync locally, you'll need docker. Follow the instruction on [docker docs](https://docs.docker.com/engine/install/) to install docker on your local machine

# Usage

## Getting Started

Follow these steps to run this project locally:

- Clone the github repo
- Install foundry on your machine
- Install foundry zksync (optional)
- Set your sepolia and mainnet rpc urls in your .env file. You can get them from [alchemy](https://www.alchemy.com/).

```# .env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your-api-key
```

- Set your etherscan api key if you want to verify your contract on [Etherscan](https://etherscan.io/).

```# .env
ETHERSCAN_API_KEY=<your api key>
```

WARNING!! DO NOT STORE YOUR PRIVATE KEY IN PLAIN TEXT IN A .ENV FILE EVEN IF IT IS NOT ASSOCIATED WITH REAL MONEY! WATCH THIS VIDEO BY [CYFRIN AUDITS](https://youtu.be/VQe7cIpaE54?si=GDZAdaltdRO8-Ond) FOR BEST PRACTICES ON HANDLING PRIVATE KEYS

## Deploy

`forge script script/DeployFundMe.s.sol`

## Testing

`forge test`

Or to test a specific test

`forge test --match-test testFunctionName`

## Test Coverage

`forge coverage`

## Local zkSync

The instructions here will allow you to work with this repo on zkSync.

### (Additional) Requirements

In addition to the requirements above, you'll need:

- [foundry-zksync](https://github.com/matter-labs/foundry-zksync)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.0.2 (816e00b 2023-03-16T00:05:26.396218Z)`.
- [docker](https://docs.docker.com/engine/install/)
  - You'll know you did it right if you can run `docker --version` and you see a response like `Docker version 20.10.7, build f0df350`.
  - Then, you'll want the daemon running, you'll know it's running if you can run `docker --info` and in the output you'll see something like the following to know it's running:

```bash
Client:
 Context:    default
 Debug Mode: false
```

### Setup local zkSync node

Run the following:

```bash
npx zksync-cli dev config
```

And select: `In memory node` and do not select any additional modules.

Then run:

```bash
npx zksync-cli dev start
```

And you'll get an output like:

```
In memory node started v0.1.0-alpha.22:
 - zkSync Node (L2):
  - Chain ID: 260
  - RPC URL: http://127.0.0.1:8011
  - Rich accounts: https://era.zksync.io/docs/tools/testing/era-test-node.html#use-pre-configured-rich-wallets
```

### Deploy to local zkSync node

```bash
make deploy-zk
```

This will deploy a mock price feed and a fund me contract to the zkSync node.

# Deployment to a testnet or mainnet

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

It is recommended that you do not use private keys in plain text but use the encrypted keys in your keystore

```
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --account <account_name> --sender <sender_address> --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
```

## Scripts

After deploying to a testnet or local net, you can run the scripts.

Using cast deployed locally example:

```
cast send <FUNDME_CONTRACT_ADDRESS> "fund()" --value 0.1ether --account <ACCOUNT_NAME>
```

or

```
forge script script/Interactions.s.sol:FundFundMe --rpc-url $SEPOLIA_RPC_URL  --account <account_name> --sender <sender_address>  --broadcast
forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $SEPOLIA_RPC_URL  --account <account_name> --sender <sender_address>  --broadcast
```

### Withdraw

```
cast send <FUNDME_CONTRACT_ADDRESS> "withdraw()"  --account <ACCOUNT_NAME>
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

# Formatting

To run code formatting:

```
forge fmt
```
