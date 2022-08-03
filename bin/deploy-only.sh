#!/bin/bash

NETWORK=$1

OPTIMIZER_RUNS=1000000

if [ "$NETWORK" == "local" ]; then
	ETH_RPC_URL="http://127.0.0.1:8545"
else
	ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"
fi

forge create Create2Factory \
	--force \
	--mnemonic-path "$MNEMONIC_PATH_1" \
	--mnemonic-index 1 \
	--rpc-url "$ETH_RPC_URL" \
	--from "$ETH_FROM" \
	--optimize --optimizer-runs="$OPTIMIZER_RUNS" \
	--extra-output-files metadata \
	--json \
	--verify
