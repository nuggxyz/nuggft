// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

abstract contract revert__NuggftV1Loan is NuggftV1Test {
    uint160 internal LOAN_TOKENID = mintable(200);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A1] - loan - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0xA1__loan__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().exec(lib.sarr160(tokenId), lib.txdata(users.frank, 0, ""));
    }

    function test__revert__NuggftV1Loan__0xA1__loan__failAsNotAgent() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().err(0xA1).from(users.dennis).exec(lib.sarr160(tokenId));
    }

    function test__revert__NuggftV1Loan__N_1__loan__passAsSelfHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().exec(lib.sarr160(tokenId), lib.txdata(users.frank, 0, ""));
    }

    function test__revert__NuggftV1Loan__0x77__loan__loanSameNuggTwice() public {
        expect.globalFrom(users.frank);

        expect.mint().g().exec{value: 1 ether}(LOAN_TOKENID);

        expect.loan().g().exec(lib.sarr160(LOAN_TOKENID));

        expect.mint().g().exec{value: nuggft.msp()}(LOAN_TOKENID + 1);

        expect.loan().g().err(0x77).exec(lib.sarr160(LOAN_TOKENID));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A6] - liquidate - "msg.sender must be operator for unexpired loan"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0xA6__liquidate__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA6__liquidate__successAsSelfExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA6__liquidate__failAsNotAgentNotExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        // forge.vm.startPrank(users.frank);
        // {
        //     nuggft.setApprovalForAll(users.mac, true);
        // }
        // forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex"7e863b48_A6");
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA6__liquidate__successAsNotAgentExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        // forge.vm.startPrank(users.frank);
        // {
        //     nuggft.setApprovalForAll(users.mac, true);
        // }
        // forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A7] - liquidate - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value + 1}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex"7e863b48_A7");
            nuggft.liquidate{value: value - 1}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value + 50 ether}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex"7e863b48_A7");
            nuggft.liquidate{value: 1}(tokenId);

            forge.vm.expectRevert(hex"7e863b48_A7");
            nuggft.liquidate{value: value / 2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        forge.vm.startPrank(users.frank);
        forge.vm.expectRevert(hex"7e863b48_A7");
        {
            nuggft.liquidate{value: 0}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A8] - rebalance - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function test__revert__NuggftV1Loan__0xA8__rebalance__successRebalanceExact() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA8__rebalance__successRebalanceWeiHigher() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value + 1}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceWeiLower() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_A8');
    //         nuggft.rebalance{value: value - 1}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA8__rebalance__successRebalanceWayHigher() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value + 50 ether}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceWayLower() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_A8');
    //         nuggft.rebalance{value: value / 2}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceZero() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_A8');
    //         nuggft.rebalance(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A9] - loanInfo - "loan exists"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function test__revert__NuggftV1Loan__0xA9__loanInfo__failDoesNotExist() public {
    //     uint160 tokenId = 42000;

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'7e863b48_A9');
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA9__loanInfo__successDoesExist() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0xA9__loanInfo__failDoesNotExistAfterLiquidate() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.loanInfo(tokenId);

    //         nuggft.liquidate{value: value}(tokenId);

    //         forge.vm.expectRevert(hex'7e863b48_A9');
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }
}
