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

RESULT=$(
    forge create NuggFatherV1 \
        --constructor-args "$SEED" \
        --mnemonic-path "$MNEMONIC_PATH_1" \
        --mnemonic-index 1 \
        --value 10ether \
        --gas-limit 25000000 \
        --rpc-url "$ETH_RPC_URL" \
        --from "$ETH_FROM" \
        --optimize --optimizer-runs="$OPTIMIZER_RUNS"
)

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

NUGGFT=$(cast call "$FATHER" 'nuggft()(address)')
xNUGGFT=$(cast call "$NUGGFT" 'xnuggftv1()(address)')
DOTNUGG=$(cast call "$NUGGFT" 'dotnuggv1()(address)')
GENESIS=$(cast call "$NUGGFT" 'genesis()(uint256)')

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

fi
