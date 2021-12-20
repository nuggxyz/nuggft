// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

library FilePure {
    using SafeCastLib for uint256;

    function decoder(bytes memory data, uint256 feature) internal pure returns (uint256[][] memory res) {
        res = abi.decode(abi.decode((data), (bytes[]))[feature], (uint256[][]));
    }

    function getLengths(uint256 input) internal pure returns (uint8[] memory res) {
        res = ShiftLib.getArray(input, 0);
    }

    function setLengths(uint256 input, uint8[] memory upd) internal pure returns (uint256 res) {
        res = ShiftLib.setArray(input, 0, upd);
    }

    function getAddress(uint256 input) internal pure returns (address res) {
        res = address(uint160(input >> 96));
    }

    function addrsetAddress(uint256 input, address update) internal pure returns (uint256 res) {
        res = input & type(uint96).max;
        res |= (uint256(uint160(update)) << 96);
    }
}
