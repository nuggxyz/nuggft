// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

function decodeMakingPrettierHappy(bytes memory input) pure returns (uint256[][] memory res){
    res = abi.decode(input, (uint256[][]));
}
