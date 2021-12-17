// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import {Print} from '../_test/utils/Print.sol';

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    function safe192(uint256 x) internal pure returns (uint192 y) {
        require(x <= type(uint192).max);
        y = uint192(x);
    }

    function safe160(uint256 x) internal pure returns (uint160 y) {
        require(x <= type(uint160).max);
        y = uint160(x);
    }

    function safe64(uint256 x) internal pure returns (uint64 y) {
        require(x <= type(uint64).max);
        y = uint64(x);
    }

    function safe32(uint256 x) internal pure returns (uint32 y) {
        require(x <= type(uint32).max);
        y = uint32(x);
    }

    function safe16(uint256 x) internal pure returns (uint16 y) {
        require(x <= type(uint16).max);
        y = uint16(x);
    }

    function safe8(uint256 x) internal pure returns (uint8 y) {
        require(x <= type(uint8).max);
        y = uint8(x);
    }
}
