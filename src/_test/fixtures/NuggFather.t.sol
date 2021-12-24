// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract fixtureTest__NuggFatherFix is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    function test_scenario_frank_has_a_token_and_spent_50_eth()
        public
        payable
        changeInUserBalance(frank, -1 * 50 ether)
        changeInNuggftBalance(50 ether)
        changeInStaked(50 ether, 1)
    {
        scenario_frank_has_a_token_and_spent_50_eth();
    }

    function test_scenario_frank_has_a_loaned_token()
        public
        payable
        changeInUserBalance(frank, -1 * 27.5 ether)
        changeInNuggftBalance(27.5 ether)
        changeInStaked(50 ether, 2)
    {
        scenario_frank_has_a_loaned_token();
    }
}
