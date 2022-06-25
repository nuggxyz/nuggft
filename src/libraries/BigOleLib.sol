// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.15;

function decodeMakingPrettierHappy(bytes memory input) pure returns (uint256[][] memory res){
    res = abi.decode(input, (uint256[][]));
}
