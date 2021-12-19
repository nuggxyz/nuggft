// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import '../_test/utils/Print.sol';

library VaultPure {
    using SafeCastLib for uint256;


    // OK
    function decoder(bytes memory data, uint256 feature) internal pure returns (uint256[][] memory res) {
        res = abi.decode(abi.decode((data), (bytes[]))[feature], (uint256[][]));
    }


    // IPOP
    function length(uint256 input, uint8 index) internal pure returns (uint16 res) {
        res = ((input >> (12 * index)) & ShiftLib.mask(12)).safe16();
    }

    function length(
        uint256 input,
        uint8 index,
        uint16 update
    ) internal pure returns (uint256 res) {
        // require(update <= 0xfff, "yoooooo");
        res = input & ShiftLib.fullsubmask(12, 12 * index);
        res |= (update << (12 * index));
    }

    // manual
    function addLengths(uint256 baseData, uint256 dataToAdd) internal pure returns (uint256 res) {
        for (uint8 i = 0; i < 8; i++) {
            res = length(res, i, length(baseData, i) + length(dataToAdd, i));
        }
        res |= (baseData & ShiftLib.fullsubmask(160, 96));
    }

    // IPOP
    function addr(uint256 input) internal pure returns (address res) {
        res = address(uint160((input >> 96) & (ShiftLib.mask(160))));
    }

    function addr(uint256 input, address update) internal pure returns (uint256 res) {
        res = input & ShiftLib.fullsubmask(160, 96);
        res |= (uint256(uint160(update)) << 96);
    }
}
