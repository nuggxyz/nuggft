// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

library VaultShiftLib {
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

    function getDataLength(uint256 data) internal pure returns (uint256 res) {
        res = (data >> 250);
    }

    function setDataLength(uint256 lengthData, uint256 feature) internal pure returns (uint256 res) {
        res = (lengthData >> (12 * feature)) & ShiftLib.mask(12);
    }

    function getFeature(uint256[] memory data) internal pure returns (uint256 res) {
        res = (data[data.length - 1] >> 32) & 0x7;
    }

    function getLengthOf(uint256 lengthData, uint256 feature) internal pure returns (uint256 res) {
        res = (lengthData >> (12 * feature)) & ShiftLib.mask(12);
    }

    function incrementLengthOf(uint256 lengthData, uint256 feature) internal pure returns (uint256 res, uint256 update) {
        update = getLengthOf(lengthData, feature) + 1;

        res = lengthData & ShiftLib.fullsubmask(12, 12 * feature);

        res |= (update << (12 * feature));
    }
}
