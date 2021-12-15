// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library SwapShiftLib {
    function eth(uint256 input) internal view returns (uint256 res) {
        return ShiftLib.getCompressed(input, 56, 160);
    }

    // 14 f's
    function eth(uint256 input, uint256 update) internal view returns (uint256 res, uint256 rem) {
        return ShiftLib.setCompressed(input, 56, 160, update);
    }

    // 9 f's
    function epoch(uint256 input, uint256 update) internal view returns (uint256 res) {
        return ShiftLib.set(input, 36, 216, update);
    }

    function epoch(uint256 input) internal view returns (uint256 res) {
        return ShiftLib.get(input, 36, 216);
    }

    function account(uint256 input) internal view returns (uint160 res) {
        return uint160(ShiftLib.get(input, 160, 0));
    }

    function account(uint256 input, uint160 update) internal view returns (uint256 res) {
        return ShiftLib.set(input, 160, 0, update);
    }

    function isOwner(uint256 input, bool update) internal view returns (uint256 res) {
        return ShiftLib.set(input, 1, 255, update ? 0x1 : 0x0);
    }

    function isOwner(uint256 input) internal view returns (bool res) {
        return ShiftLib.get(input, 1, 255) == 0x1;
    }
}