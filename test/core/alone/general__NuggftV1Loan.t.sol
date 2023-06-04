// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

import {ShiftLib} from "../../helpers/ShiftLib.sol";
import {NuggftV1Loan} from "git.nugg.xyz/nuggft/src/core/NuggftV1Loan.sol";

contract general__NuggftV1Loan is NuggftV1Test {
	uint24 internal LOAN_TOKENID;
	uint24 internal MINT_TOKENID;

	uint24 internal NUM = 4;

	function setUp() public {
		reset();

		LOAN_TOKENID = mintable(700);
		MINT_TOKENID = mintable(500);
	}

	function test__general__NuggftV1Loan__multirebalance() public {
		mintHelper(MINT_TOKENID, users.frank, 1 ether);

		uint24[] memory list = new uint24[](NUM);

		for (uint24 i = 0; i < NUM; i++) {
			mintHelper(LOAN_TOKENID + i, users.frank, nuggft.msp());
			forge.vm.deal(users.frank, 1000000000 ether);

			forge.vm.prank(users.frank);
			nuggft.loan(array.b24(LOAN_TOKENID + i));
			list[i] = LOAN_TOKENID + i;
		}

		for (uint24 i = NUM; i < NUM * 2; i++) {
			mintHelper(LOAN_TOKENID + i, users.frank, nuggft.msp());
		}

		jumpUp(33);
		uint96[] memory vfr = nuggft.vfr(list);
		forge.vm.prank(users.frank);
		nuggft.rebalance{value: lib.asum(vfr)}(list);
	}

	function test__general__NuggftV1Loan__rebalance() public {
		mintHelper(MINT_TOKENID, users.frank, 1 ether);

		uint24[] memory list = new uint24[](NUM);

		for (uint24 i = 0; i < NUM; i++) {
			mintHelper(LOAN_TOKENID + i, users.frank, nuggft.msp());
			forge.vm.prank(users.frank);
			nuggft.loan(array.b24(LOAN_TOKENID + i));
			list[i] = LOAN_TOKENID + i;
		}

		for (uint24 i = NUM; i < NUM * 2; i++) {
			mintHelper(LOAN_TOKENID + i, users.frank, nuggft.msp());
		}

		jumpUp(44);

		for (uint24 i = 0; i < NUM; i++) {
			uint96[] memory vfr = nuggft.vfr(array.b24(LOAN_TOKENID + i));
			forge.vm.prank(users.frank);
			nuggft.rebalance{value: vfr[0]}(array.b24(LOAN_TOKENID + i));
		}
	}
}
