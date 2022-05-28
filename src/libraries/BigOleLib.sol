
function decodeMakingPrettierHappy(bytes memory input) pure returns (uint256[][] memory res){
    res = abi.decode(input, (uint256[][]));
}
