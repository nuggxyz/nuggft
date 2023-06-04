// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

import {ShiftLib} from "../../helpers/ShiftLib.sol";
import {NuggftV1Loan} from "git.nugg.xyz/nuggft/src/core/NuggftV1Loan.sol";

contract stress__NuggftV1Loan is NuggftV1Test {
	uint24 internal LOAN_TOKENID;

	uint24 multiplier = 10;

	function setUp() public {
		reset();

		LOAN_TOKENID = mintable(999);

		mintHelper(LOAN_TOKENID, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(LOAN_TOKENID));
	}

	function test__stress__NuggftV1Loan__rebalance2() public globalDs {
		forge.vm.deal(users.frank, 1000000000 ether);
		forge.vm.startPrank(users.frank);

		for (uint256 i = 0; i < 10 * multiplier; i++) {
			uint96 frankStartBal = uint96(users.frank.balance);

			(, , , , , uint24 b_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

			uint24 tokenId = nuggft.epoch();
			nuggft.msp();
			uint96 value = nuggft.vfo(users.frank, tokenId);
			nuggft.offer{value: value}(tokenId);

			(, , , uint96 __fee, uint96 __earn, ) = nuggft.debt(LOAN_TOKENID);

			uint96 valueforRebal = nuggft.vfr(array.b24(LOAN_TOKENID))[0];
			nuggft.rebalance{value: valueforRebal}(array.b24(LOAN_TOKENID));

			(, , , , , uint24 a_insolventEpoch) = nuggft.debt(LOAN_TOKENID);

			{
				require(b_insolventEpoch == a_insolventEpoch || b_insolventEpoch == a_insolventEpoch - 1, "A");
				// console.log(frankStartBal, users.frank.balance);
				console.log(nuggft.eps(), nuggft.msp());

				// require(frankStartBal - value - valueforRebal == users.frank.balance, 'B');
				require(frankStartBal - value + __earn - __fee == users.frank.balance, "D");
			}

			hopUp(1);
		}

		forge.vm.stopPrank();
	}

	function test__stress__NuggftV1Loan__rebalance__multi() public globalDs {
		console.log(nuggft.eps(), nuggft.msp());
		forge.vm.deal(users.frank, 1000000000 ether);

		uint256 num = 950;
		uint24 mint1 = 1000;
		uint24[] memory tokenIds = new uint24[](num);

		for (uint24 i = mint1; i < mint1 + num; i++) {
			tokenIds[i - mint1] = mintable(i);

			mintHelper(tokenIds[i - mint1], users.frank, nuggft.msp());
			forge.vm.prank(users.frank);
			nuggft.loan(array.b24(tokenIds[i - mint1]));
		}

		// uint96 frankStartBal = uint96(users.frank.balance);

		// (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

		uint24 tokenId = nuggft.epoch();

		uint96 value = nuggft.vfo(users.frank, tokenId);

		expect.offer().from(users.frank).exec{value: value}(tokenId);

		// uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);
		// forge.vm.startPrank(users.frank);
		forge.vm.prank(users.frank);

		expect.rebalance().from(users.frank).exec{value: users.frank.balance}(tokenIds);
	}

	function test__stress__NuggftV1Loan__rebalance__multi__manyAccounts() public globalDs {
		console.log(nuggft.eps(), nuggft.msp());

		uint256 num = 950;

		uint24[] memory tokenIds = new uint24[](num);

		jumpStart();

		for (uint24 i = 0; i < (num); i++) {
			address a = address(uint160(uint256(keccak256(abi.encodePacked(i * 2699)))));

			tokenIds[i] = mintable(i);

			forge.vm.deal(a, nuggft.msp());

			mintHelper(tokenIds[i], a, a.balance);

			expect.loan().from(a).exec(array.b24(tokenIds[i]));
		}

		emit log_named_uint("balance", address(nuggft).balance);

		jumpLoan();
		// uint96 frankStartBal = uint96(users.frank.balance);

		// (, , , , uint24 b_insolventEpoch) = nuggft.loanInfo(LOAN_TOKENID);

		// uint24 tokenId = nuggft.epoch();
		// (, uint96 nextSwapAmount, uint96 senderCurrentOffer) = nuggft.check(users.frank, tokenId);

		// uint96 value = nextSwapAmount - senderCurrentOffer;
		// // forge.vm.startPrank(users.frank);
		// nuggft.offer{value: value}(tokenId);

		// uint96 valueforRebal = nuggft.valueForRebalance(LOAN_TOKENID);

		uint96[] memory vals = nuggft.vfr(tokenIds);

		uint96 tv = 0;

		for (uint256 i = 0; i < vals.length; i++) {
			tv += vals[i];
		}
		// forge.vm.deal(users.frank, tv);
		// forge.vm.prank(users.frank);
		// nuggft.rebalance{value: tv}(tokenIds);

		expect.rebalance().from(users.frank).exec{value: tv}(tokenIds);
	}

	function test__stress__NuggftV1Loan__rebalance__small() public {
		console.log(nuggft.eps(), nuggft.msp());

		jumpStart();

		address a = address(uint160(0x11111));
		address b = address(uint160(0x22222));

		uint24 tokenId = mintable(0);
		uint24 tokenId2 = mintable(1);

		mintHelper(tokenId, a, nuggft.msp());
		mintHelper(tokenId2, b, nuggft.msp());

		expect.loan().from(a).exec(array.b24(tokenId));
		expect.loan().from(b).exec(array.b24(tokenId2));

		emit log_named_uint("balance", address(nuggft).balance);

		jumpLoan();

		uint24[] memory tokenIds = array.b24(tokenId, tokenId2);

		uint96[] memory vals = nuggft.vfr(tokenIds);

		uint96 tv = vals[0] + vals[1];

		// for (uint256 i = 0; i < vals.length; i++) {
		//     tv += vals[i];
		// }
		// forge.vm.deal(users.frank, tv);
		// forge.vm.prank(users.frank);
		// nuggft.rebalance{value: tv}(tokenIds);

		expect.rebalance().from(users.frank).exec{value: tv}(tokenIds);

		nuggft.agency(tokenId);
		nuggft.agency(tokenId2);
	}
}
//   990090000000000000
//  1009891800000000000
//  1009891800000000000
