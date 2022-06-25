#!/bin/bash

NETWORK=$1

OPTIMIZER_RUNS=1000000

NUGGFT=$2
xNUGGFT=$(cast call "$NUGGFT" 'xnuggftv1()(address)')
DOTNUGG=$(cast call "$NUGGFT" 'dotnuggv1()(address)')

echo "---------------------------------------------------------"
echo "                     VERIFICATION                        "
echo "---------------------------------------------------------"
echo "verifying NuggftV1 @ $NUGGFT"
forge verify-contract "$NUGGFT" src/NuggftV1.sol:NuggftV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.14+commit.80d49f37 \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch
echo "---------------------------------------------------------"

echo "verifying xNuggftV1 @ $xNUGGFT"
forge verify-contract "$xNUGGFT" src/xNuggftV1.sol:xNuggftV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.14+commit.80d49f37 \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch
echo "---------------------------------------------------------"

echo "verifying DotnuggV1 @ $DOTNUGG"
forge verify-contract "$DOTNUGG" lib/dotnugg-v1-core/src/DotnuggV1.sol:DotnuggV1 \
    --chain "$NETWORK" \
    --compiler-version 0.8.14+commit.80d49f37 \
    --num-of-optimizations "$OPTIMIZER_RUNS" \
    --watch

echo "---------------------------------------------------------"
