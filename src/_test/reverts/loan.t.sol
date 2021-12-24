// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract revertTest__loan is NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:0] - loan - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__loan__L_0__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_call(frank, approve(address(nuggft), tokenId));

        nuggft_call(frank, loan(tokenId));
    }

    function test__revert__loan__L_0__successAsOperator() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_call(frank, approve(address(nuggft), tokenId));

        nuggft_call(frank, setApprovalForAll(address(dennis), true));

        nuggft_call(dennis, loan(tokenId));
    }

    function test__revert__loan__L_0__failAsNotOperator() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_call(frank, approve(address(nuggft), tokenId));

        nuggft_revertCall('L:0', dennis, loan(tokenId));
    }

    function test__revert__loan__N_1__failAsSelfHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_revertCall('N:1', frank, loan(tokenId));
    }

    function test__revert__loan__N_1__failAsOperatorHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_call(frank, setApprovalForAll(address(dennis), true));

        nuggft_revertCall('N:1', dennis, loan(tokenId));
    }

    function test__revert__loan__L_0__failAsNotOperatorHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        nuggft_revertCall('L:0', dennis, loan(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:1] - payoff - "msg.sender must be operator for unexpired loan"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__loan__L_1__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_1__successAsSelfExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_1__successAsOperator() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, setApprovalForAll(address(mac), true));

        nuggft_call(mac, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_1__successAsOperatorExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        nuggft_call(frank, setApprovalForAll(address(mac), true));

        nuggft_call(mac, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_1__successNotOperatorExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        nuggft_call(mac, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_1__failAsNotOperatorNotExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:1', mac, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:2] - payoff - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__loan__L_2__successPayoffExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId));
    }

    function test__revert__loan__L_2__successPayoffWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId) + 1);
    }

    function test__revert__loan__L_2__failPayoffWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:2', frank, payoff(tokenId), nuggft.valueForPayoff(tokenId) - 1);
    }

    function test__revert__loan__L_2__successPayoffWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId) + 50 ether);
    }

    function test__revert__loan__L_2__failPayoffWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:2', frank, payoff(tokenId), nuggft.valueForPayoff(tokenId) / 2);
    }

    function test__revert__loan__L_2__failPayoffZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:2', frank, payoff(tokenId), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:3] - rebalance - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__loan__L_3__successRebalanceExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId));
    }

    function test__revert__loan__L_3__successRebalanceWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) + 1);
    }

    function test__revert__loan__L_3__failRebalanceWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:3', frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) - 1);
    }

    function test__revert__loan__L_3__successRebalanceWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) + 50 ether);
    }

    function test__revert__loan__L_3__failRebalanceWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:3', frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) / 2);
    }

    function test__revert__loan__L_3__failRebalanceZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_revertCall('L:3', frank, rebalance(tokenId), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:4] - loanInfo - "loan exists"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__loan__L_4__failDoesNotExist() public {
        nuggft_revertCall('L:4', frank, loanInfo(100));
    }

    function test__revert__loan__L_4__successDoesExist() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, loanInfo(tokenId));
    }

    function test__revert__loan__L_4__failDoesNotExistAfterPayoff() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        nuggft_call(frank, loanInfo(tokenId));

        nuggft_call(frank, payoff(tokenId), nuggft.valueForPayoff(tokenId) + 1);

        nuggft_revertCall('L:4', frank, loanInfo(tokenId));
    }
}
