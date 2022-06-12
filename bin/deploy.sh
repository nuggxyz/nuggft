#!/bin/bash

SEED=$2

NETWORK=$1

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
        --value 2000000000000000000 \
        --gas-limit 25000000 \
        --rpc-url "$ETH_RPC_URL" \
        --from "$ETH_FROM" \
        --optimize --optimizer-runs=10000000
)

# BYTECODE=$(jq -r '.bytecode.object' <./out/NuggFatherV1.sol/NuggFatherV1.json)
# ARGS=$SEED
# TRANSACTION_DATA="$BYTECODE$ARGS"

echo "$RESULT"

FATHER=$(echo "$RESULT" | grep "Deployed" | sed "s/Deployed to: //g")
TX=$(echo "$RESULT" | grep "Transaction" | sed "s/Transaction hash: //g")

NUGGFT=$(cast call "$FATHER" 'nuggft()(address)')

xNUGGFT=$(cast call "$NUGGFT" 'xnuggftv1()(address)')
DOTNUGG=$(cast call "$NUGGFT" 'dotnuggv1()(address)')
echo "---------------------------------------------------------"
echo "tx hash:             $TX"
echo "nuggft deployed to:  $NUGGFT"
echo "xnuggft deployed to: $xNUGGFT"
echo "dotnugg deployed to: $DOTNUGG"
echo "father deployed to:  $FATHER"

GENESIS=$(cast call "$NUGGFT" 'genesis()(uint256)')

echo "genesis block is:    $GENESIS"
echo "---------------------------------------------------------"
