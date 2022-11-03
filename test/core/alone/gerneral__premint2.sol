// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@nuggft-v1-core/test/main.sol";

contract general__premint2 is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__premint2() public {
		uint24 token1 = nuggft.epoch();

		expect.offer().from(users.dee).exec{value: nuggft.msp()}(token1);

		jumpSwap();

		expect.claim().from(users.dee).exec(token1, users.dee);

		(uint24 token, ) = nuggft.premintTokens();

		forge.vm.startPrank(users.frank);
		forge.vm.deal(users.frank, 5 ether);

		uint16 item = xnuggft.floop(token)[9];

		nuggft.offer{value: 1 ether}(token);

		forge.vm.stopPrank();

		expect.offer().from(users.dee).exec{value: nuggft.vfo(token1, token, item)}(token1, token, item);
		expect.claim().from(users.frank).exec(token, token, item);

		jumpSwap();

		expect.claim().from(users.dee).exec(token, token1, item);
	}

	function test__premint2__vfo() public {
		(uint24 token, ) = nuggft.premintTokens();

		nuggft.vfo(users.frank, token);
	}

	function test__premint2__vfo__longtime() public {
		uint24 token1 = nuggft.epoch();

		expect.offer().from(users.dee).exec{value: nuggft.msp()}(token1);

		for (uint256 i = 0; i < INTERVAL; i++) {
			nuggft.vfo(users.frank, token1);
			hopUp(1);
		}
	}
}
