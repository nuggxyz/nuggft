#!/bin/bash

export ETH_RPC_URL="http://127.0.0.1:8545"

PROXY_CODE=$(jq -r '.bytecode.object' <./out/NuggftV1.sol/NuggftV1.json)

# DN_PROXY_CODE=$(jq -r '.bytecode.object' <./out/src/DotnuggV1.sol/DotnuggV1.json)
# DN_PROXY_CODE=$(cast abi-encode "abc(bytes)" "$DN_PROXY_CODE")

# echo "$PROXY_CODE${DN_PROXY_CODE/0x/}"

INIT_CODE_HASH=$(cast keccak "$PROXY_CODE")

NONCE=$(cast nonce "$ETH_FROM")

FACTORY=$(
	cast compute-address "$ETH_FROM" --nonce "$NONCE" |
		sed "s/Computed Address: //g"
)

echo "export INIT_CODE_HASH=$INIT_CODE_HASH"
echo "export CALLER=$ETH_FROM"
echo "export FACTORY=$FACTORY"

cd ../cuddly-waffle

cargo run --release "$FACTORY" "$ETH_FROM" "$INIT_CODE_HASH" 2
