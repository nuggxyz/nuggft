// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract swapTest__claim is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();

        // (epoch, ) = scenario_one();
    }

    // function test__swap__claim__shouldSucceedForDelegators() public {
    //     assertTrue(tryCall_claim(mac, epoch));
    //     assertTrue(tryCall_claim(dee, epoch));
    // }

    // function test__swap__claim__shouldFailForNonDelegators() public {
    //     revertCall_claim(frank, 'S:8', epoch);
    // }

    // function test__swap__claim__shouldFailForRepeatClaim() public {
    //     assertTrue(tryCall_claim(mac, epoch));
    //     assertTrue(tryCall_claim(dee, epoch));

    //     revertCall_claim(mac, 'S:8', epoch);
    //     revertCall_claim(dee, 'S:8', epoch);
    // }

    // for item swaps they can only swap one given item at a time
}
