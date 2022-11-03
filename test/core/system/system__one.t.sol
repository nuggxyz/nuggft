// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@nuggft-v1-core/test/main.sol";

abstract contract system__one is NuggftV1Test {
	using SafeCast for uint96;

	uint24 private TOKEN1;

	function test__logic__NuggftV1Proof__rotate() public {
		TOKEN1 = mintable(1);

		mintHelper(TOKEN1, users.frank, 1 ether);
		xnuggft.floop(TOKEN1);

		forge.vm.startPrank(users.frank);
		nuggft.rotate(TOKEN1, array.b8(1, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 15));
		xnuggft.floop(TOKEN1);
		forge.vm.expectRevert(hex"7e863b48_73");
		nuggft.rotate(TOKEN1, array.b8(1, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 16));

		forge.vm.expectRevert(hex"7e863b48_73");
		nuggft.rotate(TOKEN1, array.b8(0, 2, 3, 4, 5, 6, 7), array.b8(9, 10, 11, 12, 13, 14, 15));
		forge.vm.stopPrank();
	}

	function test__system__frankHasItemWar() public {
		uint24 token1 = mintable(1);
		uint24 token2 = mintable(2);

		mintHelper(token1, users.frank, nuggft.msp());

		mintHelper(token2, users.frank, nuggft.msp());

		uint16 item = xnuggft.floop(token1)[8];

		expect.sell().from(users.frank).exec(token1, item, 1 ether);

		expect.offer().from(users.frank).value(1.1 ether).exec(token2, token1, item);

		jumpSwap();

		expect.claim().from(users.frank).exec(
			array.b24(token1, token1),
			array.bAddress(address(0), address(0)),
			array.b24(token1, token2),
			array.b16(item, item)
		);
	}

	function test__system__frankMintsATokenForFree() public {
		// TOKEN1 = mintable(1);
		// // expect.stake().start(0, 1, true);
		// expect.balance().start(users.frank, 0, false);
		// expect.balance().start(address(nuggft), 0, true);
		// forge.vm.startPrank(users.frank);
		// {
		//     nuggft.mint(TOKEN1);
		// }
		// forge.vm.stopPrank();
		// // expect.stake().stop();
		// expect.balance().stop();
	}

	function test__system__frankMintsATokenFuzz(uint96 value) public {
		// TOKEN1 = mintable(1);
		// // expect.stake().start(value, 1, true);
		// forge.vm.deal(users.frank, value);
		// expect.balance().start(users.frank, value, false);
		// expect.balance().start(address(nuggft), value, true);
		// forge.vm.startPrank(users.frank);
		// {
		//     mintHelper(TOKEN1, FIX_ADDRESS, value);
		// }
		// forge.vm.stopPrank();
		// // expect.stake().stop();
		// expect.balance().stop();
	}

	// function test__system__frankMintsATokenForMaxTwice__FAILS_HORRIBLY() public {

	//     uint96 value = type(uint96).max;

	//     emit log_uint(0);

	//     expect.stake().start(value, 1, true);

	//     emit log_uint(1);

	//     forge.vm.deal(users.frank, value);

	//     expect.balance().start(users.frank, value, false);

	//     emit log_uint(2);

	//     expect.balance().start(address(nuggft), value, true);

	//     emit log_uint(3);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         mintHelper(TOKEN1, FIX_ADDRESS, value);

	//     }
	//     forge.vm.stopPrank();

	//     emit log_uint(4);

	//     expect.stopExpectStak
	// expect.balance().stop();e();

	//     emit log_uint(0);

	//     expect.stake().start(value, 1, true);

	//     emit log_uint(1);

	//     forge.vm.deal(users.frank, value);

	//     expect.balance().start(users.frank, value, false);

	//     emit log_uint(2);

	//     expect.balance().start(address(nuggft), value, true);

	//     emit log_uint(3);

	//     forge.vm.startPrank(users.frank);
	//     {
	//         mintHelper(501, FIX_ADDRESS, value);

	//     }
	//     forge.vm.stopPrank();

	//     emit log_uint(4);

	//     expect.stopExpectStak
	// expect.balance().stop();e();

	// }

	function test__system__frankMintsATokenForMax() public {
		// TOKEN1 = mintable(1);
		// uint96 value = type(uint96).max;
		// emit log_uint(0);
		// // expect.stake().start(value, 1, true);
		// emit log_uint(1);
		// forge.vm.deal(users.frank, value);
		// expect.balance().start(users.frank, value, false);
		// emit log_uint(2);
		// expect.balance().start(address(nuggft), value, true);
		// emit log_uint(3);
		// forge.vm.startPrank(users.frank);
		// {
		//     mintHelper(TOKEN1, FIX_ADDRESS, value);
		// }
		// forge.vm.stopPrank();
		// emit log_uint(4);
		// // expect.stake().stop();
		// expect.balance().stop();
	}

	function test__system__frankMintsATokenFor100gwei() public {
		// TOKEN1 = mintable(1);
		// uint96 value = 1000 gwei;
		// uint24 tokenId = TOKEN1;
		// // expect.stake().start(value, 1, true);
		// expect.balance().start(users.frank, value, false);
		// expect.balance().start(address(nuggft), value, true);
		// forge.vm.startPrank(users.frank);
		// {
		//     expect.mint().start(tokenId, users.frank, value);
		//     mintHelper(TOKEN1, FIX_ADDRESS, value);
		//     expect.mint().stop();
		// }
		// forge.vm.stopPrank();
		// // expect.stake().stop();
		// expect.balance().stop();
	}
}
