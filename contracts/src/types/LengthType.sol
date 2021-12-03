pragma solidity 0.8.10;

import 'hardhat/console.sol';
import '../libraries/ShiftLib2.sol';
import './ItemType.sol';

library LengthType {
    using ShiftLib2 for uint256;

    function length(uint256 input, ItemType.Index index) internal pure returns (uint16 res) {
        res = input.bit12((12 * uint8(index)));
    }

    function length(
        uint256 input,
        ItemType.Index index,
        uint16 update
    ) internal pure returns (uint256 res) {
        res = input.bit12((12 * uint8(index)), update);
    }
}
