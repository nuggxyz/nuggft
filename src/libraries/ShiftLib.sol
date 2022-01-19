// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library ShiftLib {
    /// @notice creates a bit mask
    /// @dev res = (2 ^ bits) - 1
    /// @param bits bit size of mask
    /// @return res the mask
    /// @custom:gas-inline ~15
    /// @custom:gas-called ~21
    function mask(uint8 bits) internal pure returns (uint256 res) {
        assembly {
            res := sub(shl(bits, 1), 1)
        }
    }

    /// @dev same as "mask" but handles the case for 256 bits
    function mask() internal pure returns (uint256 res) {
        assembly {
            res := not(res)
        }
    }

    /// @notice creates a inverse bit mask with an offset
    /// @dev used for clearing custom variables
    /// @param bits bit size of inverse mask
    /// @param pos the offset
    /// @return res imask(16,8) => 0xffff...ffff0000ff
    /// @custom:gas-inline ~15
    /// @custom:gas-called ~37
    function imask(uint8 bits, uint8 pos) internal pure returns (uint256 res) {
        res = mask(bits);
        assembly {
            res := not(shl(pos, res))
        }
    }

    function set(
        uint256 preStore,
        uint8 bits,
        uint8 pos,
        uint256 value
    ) internal pure returns (uint256 res) {
        res = imask(bits, pos);
        assembly {
            value := shl(pos, value)
            res := or(and(preStore, res), value)
        }
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
    }
}
