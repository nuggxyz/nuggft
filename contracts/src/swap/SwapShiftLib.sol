// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../libraries/ShiftLib.sol';

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library SwapShiftLib {
    function eth(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(shr(160, input), 0xFFFFFFFFFFFFFF)
            let i := and(res, 0xff)
            res := shl(mul(4, i), shr(8, res))
            res := mul(res, 0xE8D4A51000)
        }
    }

    // 14 f's
    function eth(uint256 input, uint256 update) internal pure returns (uint256 res, uint256 rem) {
        assembly {
            let in := update
            update := div(update, 0xE8D4A51000)
            for {
            } gt(update, 0xFFFFFFFFFFFF) {
            } {
                res := add(res, 0x01)
                update := shr(4, update)
            }
            update := or(shl(8, update), res)
            let out := shl(mul(4, res), shr(8, update))
            rem := sub(in, mul(out, 0xE8D4A51000))
            input := and(input, 0xffffffffff00000000000000ffffffffffffffffffffffffffffffffffffffff)
            res := or(input, shl(160, update))
        }
    }

    // 9 f's
    function epoch(uint256 input, uint256 update) internal pure returns (uint256 res) {
        assert(update <= 0xFFFFFFFFF);

        assembly {
            res := and(input, 0xf000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            res := or(res, shl(216, update))
        }
    }

    function epoch(uint256 input) internal pure returns (uint256 res) {
        assembly {
            res := and(shr(216, input), 0xFFFFFFFFF)
        }
    }

    function account(uint256 input) internal pure returns (uint160 res) {
        assembly {
            res := input
        }
    }

    function account(uint256 input, uint160 update) internal pure returns (uint256 res) {
        uint256 mask = ShiftLib.fullsubmask(160, 0);

        assembly {
            input := and(input, mask)
            res := or(input, update)
        }
    }

    function isOwner(uint256 input, bool) internal pure returns (uint256 res) {
        assembly {
            res := or(input, shl(255, 0x1))
        }
    }

    function isOwner(uint256 input) internal pure returns (bool res) {
        assembly {
            res := and(shr(255, input), 0x1)
        }
    }
}
