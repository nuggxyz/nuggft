// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__sell__0xA2 is NuggftV1Test {
	function test__revert__sell__0xA2__fail__desc() public {
		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		expect.sell().err(0xA2).from(users.mac).exec(tokenId, itemId, 1 ether);
	}

	function test__revert__sell__0xA2__pass__desc() public {
		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		expect.sell().from(users.dee).exec(tokenId, itemId, 1 ether);
	}
}
