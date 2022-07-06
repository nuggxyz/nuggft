#!/bin/bash

NETWORK="${1:-rinkeby}"

anvil --mnemonic "$MNEMONIC_PATH_1" --rpc-url "https://$NETWORK.infura.io/v3/$INFURA_KEY"
