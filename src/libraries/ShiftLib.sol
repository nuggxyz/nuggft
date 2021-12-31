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
    ) internal pure returns (uint256 postStore) {
        postStore = preStore & fullsubmask(bits, pos);

        assembly {
            value := shl(pos, value)
        }

        postStore |= value;
    }

    function get(
        uint256 store,
        uint8 bits,
        uint8 pos
    ) internal pure returns (uint256 value) {
        assembly {
            value := shr(pos, store)
        }
        value &= mask(bits);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                ARRAYS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // function getArray(uint256 store, uint8 pos) internal pure returns (uint8[] memory arr) {
    //     store = get(store, 64, pos);

    //     arr = new uint8[](8);
    //     for (uint256 i = 0; i < 8; i++) {
    //         arr[i] = uint8(store & 0xff);
    //         store >>= 8;
    //     }
    // }

    // function setArray(
    //     uint256 store,
    //     uint8 pos,
    //     uint8[] memory arr
    // ) internal pure returns (uint256 res) {
    //     for (uint256 i = 8; i > 0; i--) {
    //         res |= uint256(arr[i - 1]) << ((8 * (i - 1)));
    //     }

    //     res = set(store, 64, pos, res);
    // }
}
