// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.14;

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

library safe {
    function u40(uint256 input) internal pure returns (uint40) {
        require(input <= type(uint40).max, "safe.u40 -> unsafe conversion");
        return uint40(input);
    }

    function u40(address input) internal pure returns (uint40) {
        require(uint160(input) <= type(uint40).max, "safe.u40 (address) -> unsafe conversion");
        return uint40(uint160(input));
    }

    function u24(address input) internal pure returns (uint24) {
        require(uint160(input) <= type(uint24).max, "safe.u24 (address) -> unsafe conversion");
        return uint24(uint160(input));
    }

    function u24(uint256 input) internal pure returns (uint24) {
        require(input <= type(uint24).max, "safe.u24 -> unsafe conversion");
        return uint24(input);
    }

    function u16(uint256 input) internal pure returns (uint16) {
        require(input <= type(uint16).max, "safe.u16 -> unsafe conversion");
        return uint16(input);
    }

    function u8(uint256 input) internal pure returns (uint8) {
        require(input <= type(uint8).max, "safe.u8 -> unsafe conversion");
        return uint8(input);
    }
}
