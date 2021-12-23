// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract swapTest__delegate is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    function test__swap__delegate__mintForZero() public {
        assertTrue(!tryCall_delegate(frank, 0, epoch));
    }

    function test__swap__delegate__mintForOneEth() public payable {
        assertTrue(tryCall_delegate(frank, 10**18, epoch));
    }

    function test__swap__delegate__mintForOneThenZero() public payable {
        assertTrue(tryCall_delegate(mac, 10**18, epoch));

        assertTrue(!tryCall_delegate(dennis, 0, epoch));
    }

    function test__swap__delegate__valueMustIncrease() public payable {
        assertTrue(tryCall_delegate(mac, 5 * 10**15, epoch));

        revertCall_delegate(dennis, 4 * 10**13, 'E:1', epoch);

        assertTrue(tryCall_delegate(dennis, 10 * 10**15, epoch));

        assertTrue(tryCall_delegate(frank, 100 * 10**15, epoch));
    }

    function test__swap__delegate__commitShouldWork() public {
        scenario_one_2();

        call_delegate(dennis, 20 * 10**15, epoch);
    }

    function test__swap__delegate__shouldFailForPreviousUnclaimed() public {
        scenario_one_2();

        revertCall_delegate(mac, 12 * 10**15, 'S:EPO:12', epoch);
    }
}
