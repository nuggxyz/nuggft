// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__NuggftV1Loan is NuggftV1Test {
	uint24 internal LOAN_TOKENID;

	/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A1] - loan - "msg.sender is operator for sender"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

	function test__revert__NuggftV1Loan__0xA1__loan__successAsSelf() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

		expect.loan().exec(array.b24(tokenId), lib.txdata(users.frank, 0, ""));
	}

	function test__revert__NuggftV1Loan__0xA1__loan__failAsNotAgent() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

		expect.loan().err(0xA1).from(users.dennis).exec(array.b24(tokenId));
	}

	function test__revert__NuggftV1Loan__N_1__loan__passAsSelfHasNotApprovedContract() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_token_and_spent_50_eth();

		expect.loan().exec(array.b24(tokenId), lib.txdata(users.frank, 0, ""));
	}

	function test__revert__NuggftV1Loan__0x77__loan__loanSameNuggTwice() public {
		LOAN_TOKENID = mintable(200);
		expect.globalFrom(users.frank);

		mintHelper(LOAN_TOKENID, users.frank, 1 ether);

		expect.loan().g().exec(array.b24(LOAN_TOKENID));

		mintHelper(LOAN_TOKENID + 1, users.frank, nuggft.msp());

		expect.loan().g().err(0x77).exec(array.b24(LOAN_TOKENID));
	}

	/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A6] - liquidate - "msg.sender must be operator for unexpired loan"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

	function test__revert__NuggftV1Loan__0xA6__liquidate__successAsSelf() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA6__liquidate__successAsSelfExpired() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA6__liquidate__failAsNotAgentNotExpired() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.mac).err(0xA6).exec{value: value}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA6__liquidate__successAsNotAgentExpired() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token_that_has_expired();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value}(tokenId);
	}

	/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        hex[A7] - liquidate - "msg.value not high enough"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

	function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateExact() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateWeiHigher() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value + 1}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateWeiLower() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).err(0xA7).exec{value: value - 1}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA7__liquidate__successLiquidateWayHigher() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		expect.liquidate().from(users.frank).exec{value: value + 50}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateWayLower() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

		uint96 value = nuggft.vfl(array.b24(tokenId))[0];

		// expect.liquidate().from(users.frank).err(0xA7).exec{value: 1}(tokenId);
		expect.liquidate().from(users.frank).err(0xA7).exec{value: value / 2}(tokenId);
	}

	function test__revert__NuggftV1Loan__0xA7__liquidate__failLiquidateZero() public {
		LOAN_TOKENID = mintable(200);
		uint24 tokenId = scenario_frank_has_a_loaned_token();

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
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.valueForRebalance(tokenId);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         nuggft.rebalance{value: value}(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA8__rebalance__successRebalanceWeiHigher() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.valueForRebalance(tokenId);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         nuggft.rebalance{value: value + 1}(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceWeiLower() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.valueForRebalance(tokenId);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         forge.vm.expectRevert(hex'7e863b48_A8');
	//         nuggft.rebalance{value: value - 1}(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA8__rebalance__successRebalanceWayHigher() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.valueForRebalance(tokenId);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         nuggft.rebalance{value: value + 50 ether}(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceWayLower() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.valueForRebalance(tokenId);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         forge.vm.expectRevert(hex'7e863b48_A8');
	//         nuggft.rebalance{value: value / 2}(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA8__rebalance__failRebalanceZero() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

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
	//     uint24 tokenId = 42000;

	//     forge.vm.startPrank(users.frank);
	//     {
	//         forge.vm.expectRevert(hex'7e863b48_A9');
	//         nuggft.loanInfo(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA9__loanInfo__successDoesExist() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     forge.vm.startPrank(users.frank);
	//     {
	//         nuggft.loanInfo(tokenId);
	//     }
	//     forge.vm.stopPrank();
	// }

	// function test__revert__NuggftV1Loan__0xA9__loanInfo__failDoesNotExistAfterLiquidate() public {
	//     uint24 tokenId = scenario_frank_has_a_loaned_token();

	//     uint96 value = nuggft.vfl(array.b24(tokenId))[0];

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
