#!/bin/bash

NETWORK=$1
NUGGFT=$2

ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"

cast send "$NUGGFT" 'bye()' \
    --mnemonic-path "$MNEMONIC_PATH_1" \
    --mnemonic-index 1 \
    --from "$ETH_FROM" \
    --rpc-url "$ETH_RPC_URL"

# rinkeby
# 0x6942000062516fab40349b13131c34346c0446e8

# ropsten
# 0x69420000e30fb9095ec2a254765ff919609c1875

# goerli
# 0xb0b9cd000a5afa56d016c39470c3ec237df4e043
# 0x69420000224d0528e974c4069034756332134ad8
# 0x694200002977c420bcac022ecfd50e1316c25ccf
# 0x69420000f032d9b7897c4b9a4603b27a6dbc007f -- in use
# 0x69420000fd45cfe7b2618b4a7aadf0774f135327

# kovan
# 0x694200002e1540157c5fe987705e418ee0a9577d
