-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --account devWallet --sender 0xe5bcba588f2831d99181f1794390e88ea904640c --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-zk-sepolia:
	forge create src/FundMe.sol:FundMe --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account devWallet --constructor-args 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF --legacy --zksync