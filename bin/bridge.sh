#!/bin/bash

export ETH_RPC_URL="https://goerli.infura.io/v3/$INFURA_KEY"

export OPTIMISM_L1_BRIDGE=0x636Af16bf2f682dD3109e60102b8E1A089FedAa8

cast send --rpc-url "$ETH_RPC_URL" \
	--mnemonic-path "$MNEMONIC_PATH_1" \
	--mnemonic-index 1 \
	--value 10ether \
	$OPTIMISM_L1_BRIDGE
