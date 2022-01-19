// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract main {
    function mask(uint8 bits) internal pure returns (uint256 res) {
        assembly {
            res := sub(shl(bits, 1), 1)
        }
    }

    function imask(uint8 bits, uint8 pos) internal pure returns (uint256 res) {
        res = ~(mask(bits) << pos);
    }

    // function reun
}
