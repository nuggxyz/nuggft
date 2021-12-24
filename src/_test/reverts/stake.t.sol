// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract revertTest__stake is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
               [T:0] - addStakedShareToEth - "value of tx too low"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__stake__T_0() public {
        nuggft_call(frank, delegate(address(frank), epoch), 30 * 10**16);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:1] - value of tx too low
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:2] - value of tx too low
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
             [T:3] - subStakedShare - "user not granded permission"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__stake__T_3_reverts() public {
        (epoch, ) = scenario_one_2a();

        nuggft_revertCall('T:3', mac, withdrawStake(epoch));
    }

    function test__revert__stake__T_3_succeeds() public {
        (epoch, ) = scenario_one_2a();

        nuggft_call(dee, withdrawStake(epoch));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                         [T:4] - value of tx too low
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    // finish
    function test__revert__stake__T_4_reverts() public {
        (epoch, ) = scenario_one_2a();

        nuggft_revertCall('T:3', mac, withdrawStake(epoch));
    }

    function test__revert__stake__T_4_succeeds() public {
        (epoch, ) = scenario_one_2a();

        nuggft_call(dee, withdrawStake(epoch));
    }

    /// values add on top of each other
}
