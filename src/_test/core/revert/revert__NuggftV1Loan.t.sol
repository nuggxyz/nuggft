// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

contract revert__NuggftV1Loan is NuggftV1Test {
    uint160 internal constant LOAN_TOKENID = 700;
    uint32 epoch;

    function setUp() public {
        reset();
        forge.vm.roll(15000);

        epoch = nuggft.epoch();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[2A] - loan - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0x2A__loan__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().exec(lib.sarr160(tokenId), lib.txdata(users.frank, 0, ''));
    }

    function test__revert__NuggftV1Loan__0x2A__loan__failAsNotAgent() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().exec(lib.sarr160(tokenId), lib.txdata(users.dennis, 0, hex'2A'));
    }

    function test__revert__NuggftV1Loan__N_1__loan__passAsSelfHasNotApprovedContract() public {
        uint160 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

        expect.loan().exec(lib.sarr160(tokenId), lib.txdata(users.frank, 0, ''));
    }

    function test__revert__NuggftV1Loan__0x2C__loan__loanSameNuggTwice() public {
        expect.mint().from(users.frank).value(1 ether).exec(LOAN_TOKENID);

        expect.loan().from(users.frank).exec(lib.sarr160(LOAN_TOKENID));

        expect.mint().from(users.frank).value(1 ether).exec(LOAN_TOKENID + 1);

        expect.loan().from(users.frank).err(hex'2C').exec(lib.sarr160(LOAN_TOKENID));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[31] - liquidate - "msg.sender must be operator for unexpired loan"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0x31__liquidate__successAsSelf() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x31__liquidate__successAsSelfExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x31__liquidate__failAsNotAgentNotExpired() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        // forge.vm.startPrank(users.frank);
        // {
        //     nuggft.setApprovalForAll(users.mac, true);
        // }
        // forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        {
            forge.vm.expectRevert(hex'31');
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x31__liquidate__successAsNotAgentExpired() public {
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
        hex[32] - liquidate - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Loan__0x32__liquidate__successLiquidateExact() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x32__liquidate__successLiquidateWeiHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value + 1}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x32__liquidate__failLiquidateWeiLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex'32');
            nuggft.liquidate{value: value - 1}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x32__liquidate__successLiquidateWayHigher() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            nuggft.liquidate{value: value + 50 ether}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x32__liquidate__failLiquidateWayLower() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

        forge.vm.startPrank(users.frank);
        {
            forge.vm.expectRevert(hex'32');
            nuggft.liquidate{value: 1}(tokenId);

            forge.vm.expectRevert(hex'32');
            nuggft.liquidate{value: value / 2}(tokenId);
        }
        forge.vm.stopPrank();
    }

    function test__revert__NuggftV1Loan__0x32__liquidate__failLiquidateZero() public {
        uint160 tokenId = scenario_frank_has_a_loaned_token();

        forge.vm.startPrank(users.frank);
        forge.vm.expectRevert(hex'32');
        {
            nuggft.liquidate{value: 0}(tokenId);
        }
        forge.vm.stopPrank();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[33] - rebalance - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function test__revert__NuggftV1Loan__0x33__rebalance__successRebalanceExact() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x33__rebalance__successRebalanceWeiHigher() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value + 1}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x33__rebalance__failRebalanceWeiLower() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'33');
    //         nuggft.rebalance{value: value - 1}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x33__rebalance__successRebalanceWayHigher() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.rebalance{value: value + 50 ether}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x33__rebalance__failRebalanceWayLower() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.valueForRebalance(tokenId);

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'33');
    //         nuggft.rebalance{value: value / 2}(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x33__rebalance__failRebalanceZero() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'33');
    //         nuggft.rebalance(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[34] - loanInfo - "loan exists"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function test__revert__NuggftV1Loan__0x34__loanInfo__failDoesNotExist() public {
    //     uint160 tokenId = 42000;

    //     forge.vm.startPrank(users.frank);
    //     {
    //         forge.vm.expectRevert(hex'34');
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x34__loanInfo__successDoesExist() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }

    // function test__revert__NuggftV1Loan__0x34__loanInfo__failDoesNotExistAfterLiquidate() public {
    //     uint160 tokenId = scenario_frank_has_a_loaned_token();

    //     uint96 value = nuggft.vfl(lib.sarr160(tokenId))[0];

    //     forge.vm.startPrank(users.frank);
    //     {
    //         nuggft.loanInfo(tokenId);

    //         nuggft.liquidate{value: value}(tokenId);

    //         forge.vm.expectRevert(hex'34');
    //         nuggft.loanInfo(tokenId);
    //     }
    //     forge.vm.stopPrank();
    // }
}
