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

    // struct Memory {
    //     uint96 eth;
    //     uint32 epoch;
    //     address account;
    //     bool isOwner;
    //     bool flag;
    // }

    // function unpack(uint256 packed) internal pure returns (Memory memory m) {
    //     if (packed != 0) {
    //         m.flag = true;
    //         m.epoch = epoch(packed);
    //         m.account = account(packed);
    //         m.eth = eth(packed);
    //         m.isOwner = isOwner(packed);
    //     }
    // }

    // function pack(Memory memory m) internal pure returns (uint256 outuput, uint96 dust) {
    //     (outuput, dust) = newAgentType(m.epoch, m.account, m.eth, m.isOwner);
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                               CALCULATION
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // @test  manual
    function addIncrement(uint96 value) internal pure returns (uint96) {
        return compressEthRoundUp(((value * 10200) / 10000));
    }

    // @test  manual
    function compressEthRoundDown(uint96 value) internal pure returns (uint96) {
        return (value / COMPRESSION_PERCISION) * COMPRESSION_PERCISION;
    }

    // @test  manual
    function compressEthRoundUp(uint96 value) internal pure returns (uint96) {
        if (value % COMPRESSION_PERCISION > 0) {
            return ((value / COMPRESSION_PERCISION) + 1) * COMPRESSION_PERCISION;
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
        return (ShiftLib.get(input, 56, 160) * COMPRESSION_PERCISION).safe96();
    }

    function eth(uint256 input, uint96 update) internal pure returns (uint256 cache, uint96 rem) {
        rem = update % COMPRESSION_PERCISION;
        cache = ShiftLib.set(input, 56, 160, update / COMPRESSION_PERCISION);
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
