// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from './SafeCastLib.sol';

library ShiftLib {
    using SafeCastLib for uint256;

    /// @notice creates a bit mask
    /// @dev res = (2 ^ bits) - 1
    /// @param bits bit size of mask
    /// @return res the mask
    function mask(uint8 bits) internal pure returns (uint256 res) {
        assembly {
            res := sub(shl(bits, 1), 1)
        }
    }

    function fullsubmask(uint8 bits, uint8 pos) internal pure returns (uint256 res) {
        res = ~(mask(bits) << pos);
    }

    function set(
        uint256 preStore,
        uint8 bits,
        uint8 pos,
        uint256 value
    ) internal pure returns (uint256 res) {
        // res = preStore & fullsubmask(bits, pos);
        res = fullsubmask(bits, pos);

        assembly {
            value := shl(pos, value)
            res := or(and(preStore, res), value)
        }

        // res |= value;
    }

    function get(
        uint256 store,
        uint8 bits,
        uint8 pos
    ) internal pure returns (uint256 res) {
        res = mask(bits);
        assembly {
            res := and(shr(pos, store), res)
        }
        // value &= mask(bits);
    }
}
