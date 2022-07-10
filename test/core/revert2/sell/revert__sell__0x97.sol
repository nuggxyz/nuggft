// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__sell__0x97 is NuggftV1Test {
	function test__revert__sell__0x97__fail__desc() public {
		(uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

		expect.sell().from(users.dee).exec(tokenId, itemId, floor * 2);
	}

	function test__revert__sell__0x97__pass__desc() public {
		(uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

		expect.claim().from(users.dee).exec(tokenId, tokenId, itemId);

		expect.sell().from(users.dee).exec(tokenId, itemId, floor);
	}
}
