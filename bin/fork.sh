#!/bin/bash

NETWORK="${1:-rinkeby}"

anvil --tx-origin "$ETH_FROM" --mnemonic "$MNEMONIC_PATH_1" -vv --rpc-url "https://$NETWORK.infura.io/v3/$INFURA_KEY"
