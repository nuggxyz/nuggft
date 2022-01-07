// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

contract revert__NuggftV1Loan is NuggftV1Test {
    uint32 epoch;

    using UserTarget for address;

    function setUp() public {
        reset();
        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:0] - loan - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__L_0__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldPass(frank, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(frank, loan(tokenId));
    }

    function test__revert__NuggftV1Loan__L_0__failAsOperator() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldPass(frank, approve(address(nuggft), tokenId));

        _nuggft.shouldPass(frank, setApprovalForAll(address(dennis), true));

        _nuggft.shouldFail('L:0', dennis, loan(tokenId));
    }

    function test__revert__NuggftV1Loan__L_0__failAsNotOperator() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldPass(frank, approve(address(nuggft), tokenId));

        _nuggft.shouldFail('L:0', dennis, loan(tokenId));
    }

    function test__revert__NuggftV1Loan__N_1__failAsSelfHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldFail('N:1', frank, loan(tokenId));
    }

    function test__revert__NuggftV1Loan__L_0__failAsOperatorHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldPass(frank, setApprovalForAll(address(dennis), true));

        _nuggft.shouldFail('L:0', dennis, loan(tokenId));
    }

    function test__revert__NuggftV1Loan__L_0__failAsNotOperatorHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        _nuggft.shouldFail('L:0', dennis, loan(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:1] - liquidate - "msg.sender must be operator for unexpired loan"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__L_1__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_1__successAsSelfExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_1__successAsOperator() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, setApprovalForAll(address(mac), true));

        _nuggft.shouldPass(mac, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_1__successAsOperatorExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        _nuggft.shouldPass(frank, setApprovalForAll(address(mac), true));

        _nuggft.shouldPass(mac, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_1__successNotOperatorExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        _nuggft.shouldPass(mac, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_1__failAsNotOperatorNotExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:1', mac, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:2] - liquidate - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__L_2__successLiquidateExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId));
    }

    function test__revert__NuggftV1Loan__L_2__successLiquidateWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId) + 1);
    }

    function test__revert__NuggftV1Loan__L_2__failLiquidateWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:2', frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId) - 1);
    }

    function test__revert__NuggftV1Loan__L_2__successLiquidateWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId) + 50 ether);
    }

    function test__revert__NuggftV1Loan__L_2__failLiquidateWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:2', frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId) / 2);
    }

    function test__revert__NuggftV1Loan__L_2__failLiquidateZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:2', frank, liquidate(tokenId), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:3] - rebalance - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__L_3__successRebalanceExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId));
    }

    function test__revert__NuggftV1Loan__L_3__successRebalanceWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) + 1);
    }

    function test__revert__NuggftV1Loan__L_3__failRebalanceWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:3', frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) - 1);
    }

    function test__revert__NuggftV1Loan__L_3__successRebalanceWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) + 50 ether);
    }

    function test__revert__NuggftV1Loan__L_3__failRebalanceWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:3', frank, rebalance(tokenId), nuggft.valueForRebalance(tokenId) / 2);
    }

    function test__revert__NuggftV1Loan__L_3__failRebalanceZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldFail('L:3', frank, rebalance(tokenId), 0);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [L:4] - loanInfo - "loan exists"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__L_4__failDoesNotExist() public {
        _nuggft.shouldFail('L:4', frank, loanInfo(100));
    }

    function test__revert__NuggftV1Loan__L_4__successDoesExist() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, loanInfo(tokenId));
    }

    function test__revert__NuggftV1Loan__L_4__failDoesNotExistAfterLiquidate() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        _nuggft.shouldPass(frank, loanInfo(tokenId));

        _nuggft.shouldPass(frank, liquidate(tokenId), nuggft.valueForLiquidate(tokenId) + 1);

        _nuggft.shouldFail('L:4', frank, loanInfo(tokenId));
    }
}
