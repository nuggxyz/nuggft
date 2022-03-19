#!/bin/bash

ETHERSCSN_APIKEY=$1

CURRENT_SAFE_GAS_PRICE=$(
    curl --silent "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$ETHERSCSN_APIKEY" |
        jq -r ".result.SafeGasPrice"
)

echo "currentgas price: $CURRENT_SAFE_GAS_PRICE"

if [ $((CURRENT_SAFE_GAS_PRICE)) -lt 20 ]; then
    osascript -e "display notification \"gas price is at $CURRENT_SAFE_GAS_PRICE\" with title \"Gas Price Low\" sound name \"Submarine\""
fi
sleep 5
