// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../../fixtures/NuggFather.fix.sol';

import {SwapCore} from '../../../swap/SwapCore.sol';

import {Swap} from '../../../swap/SwapStorage.sol';

contract SwapCoreTest__delegate is t, NuggFatherFix {
    function setUp() public {
        reset();
    }

    function test__SwapCore__delegate__mintForZero() public {
        uint32 epoch = nuggft.epoch();

        emit log_named_uint('epoch', epoch);

        assertTrue(!tryCall_delegate(frank, 0, epoch));
    }

    function test__SwapCore__delegate__mintForOneEth() public payable {
        uint32 epoch = nuggft.epoch();

        assertTrue(tryCall_delegate(frank, 10**18, epoch));
    }

    function test__SwapCore__delegate__mintForOneThenZero() public payable {
        uint32 epoch = nuggft.epoch();

        assertTrue(tryCall_delegate(mac, 10**18, epoch));

        assertTrue(!tryCall_delegate(dennis, 0, epoch));
    }

    function test__SwapCore__delegate__valueMustIncrease() public payable {
        uint32 epoch = nuggft.epoch();

        assertTrue(tryCall_delegate(mac, 5 * 10**15, epoch));

        revertCall_delegate(dennis, 4 * 10**13, 'E:1', epoch);

        assertTrue(tryCall_delegate(dennis, 10 * 10**15, epoch));

        assertTrue(tryCall_delegate(frank, 100 * 10**15, epoch));
    }
}
