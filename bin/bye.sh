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
# 0x69420000c537a53ff966610aee8c8884f02c88f8

# kovan
# 0x694200002e1540157c5fe987705e418ee0a9577d
