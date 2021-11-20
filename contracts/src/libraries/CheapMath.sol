// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library CheapMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 res) {
        assembly {
            res := add(a, b)
        }
    }

    function pow10(uint16 a, uint8 b) internal pure returns (uint256 res) {
        assembly {
            res := exp(a, mul(b, 10))
        }
    }
}
