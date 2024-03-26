-include .env

test-fork:
	@echo 'Starting testing!!'
	@forge t --rpc-url ${LOCAL_RPC} --match-path test/MultiSwap.t.sol -vvv

fork-sepolia:
	@echo "Building broker binary..."
	@anvil --fork-url ${SEPOLIA_RPC_URL}

deploy-sepolia:
	@echo "Deploying to sepolia..."
	@forge script ./script/MultiSwap.s.sol --rpc-url ${SEPOLIA_RPC_URL}  --broadcast --etherscan-api-key ${ETHERSCAN_KEY} --verifier-url ${SEPOLIA_RPC_URL} --verify -vvvvv