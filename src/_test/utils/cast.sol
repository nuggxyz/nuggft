// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

library cast {
    function i192(uint256 input) internal pure returns (int192) {
        return int192(int256(input));
    }

    function u256(int256 input) internal pure returns (uint256) {
        return uint256(input);
    }

    function u96(int192 input) internal pure returns (uint96) {
        return uint96(uint256(int256(input)));
    }
}
