#!/bin/bash

NETWORK=$1

SEED=$2

OPTIMIZER_RUNS=10000000

if [ "$NETWORK" == "local" ]; then
    ETH_RPC_URL="http://127.0.0.1:8545"
else
    ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"
fi

echo "$SEED"

# RESULT=$(
# 	forge create DotnuggV1 \
# 		--constructor-args "$SEED" \
# 		--private-key 0xedf370e9795f88d24d19c41c85ad608e3084742d6e431563f3dfb9a0028b4bca \
# 		--gas-limit 15000000 \
# 		--value 10ether \
# 		--rpc-url "$ETH_RPC_URL" \
# 		--from "$ETH_FROM" \
# 		--optimize --optimizer-runs="$OPTIMIZER_RUNS" \
# 		--extra-output-files metadata
# )
# --mnemonic-index 1 \

echo "---------------------------------------------------------"
echo "               forge create NuggFatherV1                 "
echo "---------------------------------------------------------"

echo "$RESULT"

echo "---------------------------------------------------------"
echo ""

echo "---------------------------------------------------------"
echo "                       ADDRESSES                         "
echo "---------------------------------------------------------"

FATHER=$(echo "$RESULT" | grep "Deployed" | sed "s/Deployed to: //g")
TX=$(echo "$RESULT" | grep "Transaction" | sed "s/Transaction hash: //g")

NUGGFT=$(cast call "$FATHER" 'nuggft()(address)' --rpc-url "$ETH_RPC_URL")
xNUGGFT=$(cast call "$NUGGFT" 'xnuggftv1()(address)' --rpc-url "$ETH_RPC_URL")
DOTNUGG=$(cast call "$NUGGFT" 'dotnuggv1()(address)' --rpc-url "$ETH_RPC_URL")
GENESIS=$(cast call "$NUGGFT" 'genesis()(uint256)' --rpc-url "$ETH_RPC_URL")

echo "tx hash:             $TX"
echo "nuggft deployed to:  $NUGGFT"
echo "xnuggft deployed to: $xNUGGFT"
echo "dotnugg deployed to: $DOTNUGG"
echo "father deployed to:  $FATHER"
echo "genesis block is:    $GENESIS"
echo "---------------------------------------------------------"

if [ "$NETWORK" != "local" ]; then
    echo ""
    echo "sleeping for 15 seconds"
    sleep 15
    echo ""
    echo "---------------------------------------------------------"
    echo "                     VERIFICATION                        "
    echo "---------------------------------------------------------"
    echo "verifying NuggftV1 @ $NUGGFT"
    forge verify-contract "$NUGGFT" src/NuggftV1.sol:NuggftV1 \
        --chain "$NETWORK" \
        --compiler-version 0.8.20+commit.a1b79de6 --num-of-optimizations "$OPTIMIZER_RUNS" \
        --watch
    echo "---------------------------------------------------------"

    echo "verifying xNuggftV1 @ $xNUGGFT"
    forge verify-contract "$xNUGGFT" src/xNuggftV1.sol:xNuggftV1 \
        --chain "$NETWORK" \
        --compiler-version 0.8.20+commit.a1b79de6 --num-of-optimizations "$OPTIMIZER_RUNS" \
        --watch
    echo "---------------------------------------------------------"

    echo "verifying DotnuggV1 @ $DOTNUGG"
    forge verify-contract "$DOTNUGG" ../dotnugg/src/DotnuggV1.sol:DotnuggV1 \
        --chain "$NETWORK" \
        --compiler-version 0.8.20+commit.a1b79de6 --num-of-optimizations "$OPTIMIZER_RUNS" \
        --watch

    echo "---------------------------------------------------------"

fi
