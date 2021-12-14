// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library ShiftLib {
    function fullsubmask(uint256 bits, uint256 offset) internal pure returns (uint256 res) {
        res = ~(mask(bits) << offset);
    }

    function mask(uint256 bits) internal pure returns (uint256 res) {
        assembly {
            res := sub(exp(2, bits), 1)
        }
    }
}
