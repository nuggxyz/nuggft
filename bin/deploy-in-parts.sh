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
    forge create NuggFatherV1PartA \
        --force \
        --legacy \
        --mnemonic-path "$MNEMONIC_PATH_1" \
        --mnemonic-index 1 \
        --gas-limit 15000000 \
        --rpc-url "$ETH_RPC_URL" \
        --from "$ETH_FROM" \
        --optimize --optimizer-runs="$OPTIMIZER_RUNS" \
        --extra-output-files metadata
)

echo "---------------------------------------------------------"
echo "               forge create NuggFatherV1 A               "
echo "---------------------------------------------------------"

echo "$RESULT"

FATHERA=$(echo "$RESULT" | grep "Deployed" | sed "s/Deployed to: //g")
TX=$(echo "$RESULT" | grep "Transaction" | sed "s/Transaction hash: //g")
DOTNUGG=$(cast call "$FATHERA" 'dotnugg()(address)' --rpc-url "$ETH_RPC_URL")

echo "---------------------------------------------------------"
echo "                       EXPORTS                           "
echo "---------------------------------------------------------"

echo "tx hash:             $TX"
echo "dotnugg deployed to: $DOTNUGG"
echo "fatherA deployed to: $FATHERA"

echo "---------------------------------------------------------"
echo "               forge create NuggFatherV1 B             "
echo "---------------------------------------------------------"

RESULT=$(
    forge create NuggftV1 \
        --force \
        --legacy \
        --mnemonic-path "$MNEMONIC_PATH_1" \
        --mnemonic-index 1 \
        --gas-limit 15000000 \
        --rpc-url "$ETH_RPC_URL" \
        --from "$ETH_FROM" \
        --optimize --optimizer-runs="$OPTIMIZER_RUNS" \
        --extra-output-files metadata \
        --constructor-args "$DOTNUGG"

)

echo "$RESULT"

FATHERB=$(echo "$RESULT" | grep "Deployed" | sed "s/Deployed to: //g")
TX=$(echo "$RESULT" | grep "Transaction" | sed "s/Transaction hash: //g")

echo "---------------------------------------------------------"
echo "                       EXPORTS                           "
echo "---------------------------------------------------------"

echo "tx hash:             $TX"
echo "fatherA deployed to: $FATHERB"
echo ""
echo "---------------------------------------------------------"
echo "               forge create NuggFatherV1 C             "
echo "---------------------------------------------------------"

RESULT=$(
    forge create NuggFatherV1PartC \
        --force --legacy \
        --mnemonic-path "$MNEMONIC_PATH_1" \
        --mnemonic-index 1 \
        --value 1ether \
        --gas-limit 15000000 \
        --rpc-url "$ETH_RPC_URL" \
        --from "$ETH_FROM" \
        --optimize --optimizer-runs="$OPTIMIZER_RUNS" \
        --extra-output-files metadata \
        --constructor-args "$SEED" "$DOTNUGG"

)

# # RESULT=$(
# 	forge create NuggFatherV1PartC \
# 		--force \
# 		--mnemonic-path "$MNEMONIC_PATH_1" \
# 		--mnemonic-index 1 \
# 		--value 10ether \
# 		--gas-limit 15000000 \
# 		--rpc-url "$ETH_RPC_URL" \
# 		--from "$ETH_FROM" \
# 		--optimize --optimizer-runs=10000000 \
# 		--extra-output-files metadata \
# 		--constructor-args 0x69d96895f1189018cb82f276c710b23186c355885ae6e4c92e6e801c49e0f4ab 0xdde686b5bbbe07a741a9b7f428e46ee42efd45c8

# # )

echo "$RESULT"

echo "---------------------------------------------------------"
echo "                       EXPORTS                           "
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
echo "fatherB deployed to: $FATHER"
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

# gas price= "0.000000000001"
# gas used = '13421737'

# 0.00001342173

# l1 gas used="917186"
# l1 gs price=.000000024699166503
# l1 scalar=1

# 0.02265372972
