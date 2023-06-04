#!/bin/bash

NETWORK=$1

OPTIMIZER_RUNS=10000000

if [ "$NETWORK" == "local" ]; then
    ETH_RPC_URL="http://127.0.0.1:8545"
else
    ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"
fi

NUGGFT=$2
xNUGGFT=$(cast call "$NUGGFT" 'xnuggftv1()(address)')
DOTNUGG=$(cast call "$NUGGFT" 'dotnuggv1()(address)')

echo "---------------------------------------------------------"
echo "                     VERIFICATION                        "
echo "---------------------------------------------------------"
echo "verifying NuggftV1 @ $NUGGFT"
forge verify-contract "$NUGGFT" src/NuggftV1.sol:NuggftV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.17+commit.8df45f5f \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch
echo "---------------------------------------------------------"

echo "verifying xNuggftV1 @ $xNUGGFT"
forge verify-contract "$xNUGGFT" src/xNuggftV1.sol:xNuggftV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.17+commit.8df45f5f \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch
echo "---------------------------------------------------------"

echo "verifying DotnuggV1 @ $DOTNUGG"
forge verify-contract "$DOTNUGG" lib/dotnugg/src/DotnuggV1.sol:DotnuggV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.17+commit.8df45f5f \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch

echo "---------------------------------------------------------"
