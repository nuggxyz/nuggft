#!/bin/bash

PK="$1"

ETH_RPC_URL="http://localhost:8545"

SEED=0x00000000000000000000000000000000000000000000000000000000000000

OPTIMIZER_RUNS="10000000"

deployment() {
	forge create NuggFatherV1 \
		--constructor-args "$SEED" \
		--private-key "$PK" \
		--value 10ether \
		--gas-limit 26500000 \
		--rpc-url "$ETH_RPC_URL" \
		--optimize --optimizer-runs="$OPTIMIZER_RUNS" \
		--extra-output-files metadata
}

pass() {
	forge clean
	deployment
}

fail() {
	deployment
}

echo "========================================================="
echo "start try 1 - should pass"
pass
echo "end try 1 - should have passed"
echo "========================================================="
echo "start try 2 - fails with 'could not find artifact: NuggFatherV1'"
fail
echo "end try 2 - should have failed"
echo "========================================================="
echo "start try 3 - fails with 'could not find artifact: NuggFatherV1'"
fail
echo "end try 3 - should have failed"
