#!/bin/bash

NETWORK=$1
NUGGFT=$2

if [ "$NETWORK" == "local" ]; then
    ETH_RPC_URL="http://127.0.0.1:8545"
else
    ETH_RPC_URL="https://$NETWORK.infura.io/v3/$INFURA_KEY"
fi

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
# bin/bye.sh goerli 0xb0b9cd000a5afa56d016c39470c3ec237df4e043
# bin/bye.sh goerli 0x69420000224d0528e974c4069034756332134ad8
# bin/bye.sh goerli 0x694200002977c420bcac022ecfd50e1316c25ccf
# bin/bye.sh goerli 0x69420000f032d9b7897c4b9a4603b27a6dbc007f
# bin/bye.sh goerli 0x69420000fd45cfe7b2618b4a7aadf0774f135327
# 0x69420000923F739820f977a4b67aBa42C2C3b216
# --------
# 0x7ccd9a783e43845f3ae37e83b4a696b0cfab114c
# 0x694200008FaB2B40054C3c0762f2f34505e484E6 -- in use
# 0x694200000FdFBc056b59c498c60A7330255A9755
# kovan
# 0x694200002e1540157c5fe987705e418ee0a9577d

# //➜  nuggft git:(main) ✗ bin/bye.sh goerli 0x69420000813E88EA1900125E91b61E1028C4C978
# //➜  nuggft git:(main) ✗ bin/bye.sh goerli 0x69420000Bad0605988626169E32aa82FB3981add
