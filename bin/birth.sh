#!/bin/bash


PRIV=$(exec jq '.users.dub6ix.priv' ./config.json --raw-output)

while true
do
cast send $@ 'mint(uint160)' 50 \
    --private-key $PRIV \
    --value 500000000000000 \
    --gas 1000000
done
