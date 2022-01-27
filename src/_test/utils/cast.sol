// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

library cast {
    function i192(uint256 input) internal pure returns (int192) {
        return int192(int256(input));
    }
}
