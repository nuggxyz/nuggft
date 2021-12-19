// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

/// @title SwapPure
/// @author dub6ix.eth
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
library SwapPure {
    using SafeCastLib for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            CALCULATION
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // @test  manual
    function addIncrement(uint256 value) internal pure returns (uint256) {
        return (value * 10100) / 10000;
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            SHIFT HELPERS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
    // @test input output unit test
    // type(uint96).max / 10**13 = 0x01C25C268497681 =  7922816251426433
    // type(uint56).max          = 0x100000000000000 = 72057594037927936
    function eth(uint256 input) internal pure returns (uint96 res) {
        return (ShiftLib.get(input, 56, 160) * 0x9184E72A000).safe96();
    }

    function eth(uint256 input, uint96 update) internal pure returns (uint256 cache, uint96 rem) {
        rem = update % uint96(0x9184E72A000);
        cache = ShiftLib.set(input, 56, 160, update / uint96(0x9184E72A000));
    }

    // @test  input output unit test
    function epoch(uint256 input, uint32 update) internal pure returns (uint256 res) {
        return ShiftLib.set(input, 32, 216, update);
    }

    function epoch(uint256 input) internal pure returns (uint32 res) {
        return ShiftLib.get(input, 32, 216).safe32();
    }

    // @test  input output unit test
    function account(uint256 input) internal pure returns (uint160 res) {
        res = ShiftLib.get(input, 160, 0).safe160();
    }

    function account(uint256 input, uint160 update) internal pure returns (uint256 output) {
        output = ShiftLib.set(input, 160, 0, update);
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
    function buildSwapData(
        uint32 _epoch,
        uint160 _account,
        uint96 _eth,
        bool _isOwner
    ) internal pure returns (uint256 res, uint96 dust) {
        res = epoch(res, _epoch);
        res = account(res, _account);
        if (_isOwner) res = isOwner(res, true);
        (res, dust) = eth(res, _eth);
        res = flag(res);
    }

    // @test  manual
    function updateSwapData(
        uint256 data,
        uint160 _account,
        uint96 _eth
    )
        internal
        pure
        returns (
            uint256 res,
            uint256 increment,
            uint256 dust
        )
    {
        return updateSwapDataWithEpoch(data, epoch(data), _account, _eth);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 data,
        uint32 _epoch,
        uint160 _account,
        uint96 _eth
    )
        internal
        pure
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        uint96 baseEth = eth(data);

        require(addIncrement(baseEth) < _eth);

        (res, dust) = buildSwapData(_epoch, _account, _eth, false);

        increment = _eth - baseEth;
    }
}
