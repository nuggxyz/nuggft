// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library NuggftV1AgentType {
    using SafeCastLib for uint256;

    // 10**13
    uint96 constant COMPRESSION_PERCISION = 0x9184E72A000;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                               CALCULATION
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // @test  manual
    function addIncrement(uint96 value) internal pure returns (uint96 res) {
        res = value * 10200;
        assembly {
            res := div(res, 10000)
        }
        // return compressEthRoundUp((MathLib.safeDivNonZero96(value * 10200, 10000)));
    }

    // @test  manual
    function compressEthRoundDown(uint96 value) internal pure returns (uint96 res) {
        // res = MathLib.safeDivNonZero96(value / COMPRESSION_PERCISION) * COMPRESSION_PERCISION;

        assembly {
            res := mul(div(value, COMPRESSION_PERCISION), COMPRESSION_PERCISION)
        }
    }

    // @test  manual
    function compressEthRoundUp(uint96 value) internal pure returns (uint96 res) {
        assembly {
            res := mod(value, COMPRESSION_PERCISION)
        }
        if (res > 0) {
            assembly {
                res := mul(add(div(value, COMPRESSION_PERCISION), 1), COMPRESSION_PERCISION)
            }
            // return ((value / COMPRESSION_PERCISION) + 1) * COMPRESSION_PERCISION;
        } else {
            return compressEthRoundDown(value);
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                              SHIFT HELPERS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    // @test input output unit test
    // type(uint96).max / 10**13 = 0x01C25C268497681 =  7922816251426433
    // type(uint56).max          = 0x100000000000000 = 72057594037927936
    function eth(uint256 input) internal pure returns (uint96 res) {
        input = ShiftLib.get(input, 56, 160);
        assembly {
            input := mul(input, COMPRESSION_PERCISION)
        }
        return input.safe96();
    }

    function eth(uint256 input, uint96 update) internal pure returns (uint256 cache, uint96 rem) {
        assembly {
            rem := mod(update, COMPRESSION_PERCISION)
            update := div(update, COMPRESSION_PERCISION)
        }
        // rem = update % COMPRESSION_PERCISION;
        cache = ShiftLib.set(input, 56, 160, update);
    }

    // @test  input output unit test
    function epoch(uint256 input, uint32 update) internal pure returns (uint256 res) {
        return ShiftLib.set(input, 32, 216, update);
    }

    function epoch(uint256 input) internal pure returns (uint32 res) {
        return ShiftLib.get(input, 32, 216).safe32();
    }

    // @test  input output unit test
    function account(uint256 input) internal pure returns (address res) {
        res = address(ShiftLib.get(input, 160, 0).safe160());
    }

    function account(uint256 input, address update) internal pure returns (uint256 output) {
        output = ShiftLib.set(input, 160, 0, uint160(update));
    }

    // @test  input output unit test
    function isOwner(uint256 input, bool update) internal pure returns (uint256 res) {
        return ShiftLib.set(input, 1, 255, update ? 0x1 : 0x0);
    }

    function isOwner(uint256 input) internal pure returns (bool output) {
        output = ShiftLib.get(input, 1, 255) == 0x1;
    }

    // @test  check to see if it does this - will be easy
    function flag(uint256 input) internal pure returns (uint256 res) {
        res = ShiftLib.set(input, 1, 254, 0x01);
    }

    // @test  manual
    function newAgentType(
        uint32 _epoch,
        address _account,
        uint96 _eth,
        bool _isOwner
    ) internal pure returns (uint256 res, uint96 dust) {
        res = epoch(res, _epoch);
        res = account(res, _account);
        if (_isOwner) res = isOwner(res, true);
        (res, dust) = eth(res, _eth);
        res = flag(res);
    }
}
