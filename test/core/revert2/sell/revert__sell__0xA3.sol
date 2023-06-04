// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__sell__0xA3 is NuggftV1Test {
	function test__revert__sell__0xA3__fail__desc() public {
		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		expect.sell().from(users.dee).exec(tokenId, 1.2 ether);

		expect.offer().from(users.mac).value(1.3 ether).exec(tokenId);

		expect.sell().err(0xA3).from(users.mac).exec(tokenId, itemId, 2 ether);
	}

	function test__revert__sell__0xA3__pass__desc() public {
		jumpStart();

		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		expect.sell().from(users.dee).exec(tokenId, 1.2 ether);

		expect.offer().from(users.mac).value(1.3 ether).exec(tokenId);

		jumpSwap();

		expect.claim().from(users.mac).exec(tokenId, users.mac);

		expect.sell().from(users.mac).exec(tokenId, itemId, 2 ether);
	}
}
