#!/bin/bash

NETWORK=$1

GAS=${2:-29999999}

if [ "$NETWORK" == "local" ]; then
	# ETH_RPC_URL="http://127.0.0.1:8545"
	export HTTP_PROXY="http://127.0.0.1:8889"
	anvil --mnemonic "$MNEMONIC_PATH_1" --rpc-url "$ETH_RPC_URL" --steps-tracing

else
	anvil --mnemonic "$MNEMONIC_PATH_1" --rpc-url "$ETH_RPC_URL" --silent --gas-limit "$GAS"

	# ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"
fi
