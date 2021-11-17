// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../src/libraries/QuadMath.sol';

contract QuadMath_Test {
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) external pure returns (uint256) {
        return QuadMath.mulDiv(x, y, z);
    }

    function mulDivRoundingUp(
        uint256 x,
        uint256 y,
        uint256 z
    ) external pure returns (uint256) {
        return QuadMath.mulDivRoundingUp(x, y, z);
    }
}
