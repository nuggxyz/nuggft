// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

library LengthType {
    function length(uint256 input, uint256 index) internal pure returns (uint256 res) {
        res = (input >> (12 * index)) & ShiftLib.mask(12);
    }

    function length(
        uint256 input,
        uint256 index,
        uint256 update
    ) internal pure returns (uint256 res) {
        uint256 hello = ShiftLib.fullsubmask(12, 12 * index);
        res = input & hello;
        res |= (update << (12 * index));
    }
}
