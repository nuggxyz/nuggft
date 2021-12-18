// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {SwapCore} from '../../../swap/SwapCore.sol';

import {Swap} from '../../../swap/SwapStorage.sol';

contract SwapCoreTest__delegate is t {
    function setUp() public {}

    function test__SwapCore__delegate__a() public {
        fvm.roll(1);
        fvm.roll(2);

        SwapCore.delegate(1);

        (, Swap.Memory memory m) = Swap.loadTokenSwap(4, msg.sender);

        assertTrue(m.swapData != 0);
    }
}
