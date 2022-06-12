#!/bin/bash

export ETH_RPC_URL="http://127.0.0.1:8545"

PROXY_CODE=$(jq -r '.bytecode.object' <./out/NuggftV1.sol/NuggftV1.json)

INIT_CODE_HASH=$(cast keccak "$PROXY_CODE")

NONCE=$(cast nonce "$ETH_FROM")

NUGG_FATHER=$(
    cast compute-address "$ETH_FROM" --nonce "$NONCE" |
        sed "s/Computed Address: //g"
)

echo "export INIT_CODE_HASH=$INIT_CODE_HASH"
echo "export CALLER=$ETH_FROM"
echo "export FACTORY=$NUGG_FATHER"
