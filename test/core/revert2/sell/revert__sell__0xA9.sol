// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__sell__0xA9 is NuggftV1Test {
	function test__revert__sell__0xA9__fail__desc() public {
		uint24 TOKEN1 = mintable(0);

		jumpStart();

		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		mintHelper(TOKEN1, users.mac, nuggft.msp());

		expect.sell().from(users.dee).exec(tokenId, itemId, .1 ether);

		expect.offer().from(users.mac).value(nuggft.vfo(TOKEN1, tokenId, itemId)).exec(TOKEN1, tokenId, itemId);

		jumpSwap();

		expect.claim().from(users.mac).exec(tokenId, TOKEN1, itemId);

		expect.sell().from(users.dee).err(0xA9).exec(tokenId, itemId, .1 ether);
	}

	function test__revert__sell__0xA9__pass__desc() public {
		uint24 TOKEN1 = mintable(0);

		jumpStart();

		(uint24 tokenId, uint16 itemId, ) = scenario_dee_has_a_token_and_can_sell_an_item();

		mintHelper(TOKEN1, users.mac, nuggft.msp());

		expect.sell().from(users.dee).exec(tokenId, itemId, .1 ether);

		expect.offer().from(users.mac).value(nuggft.vfo(TOKEN1, tokenId, itemId)).exec(TOKEN1, tokenId, itemId);

		jumpSwap();

		expect.claim().from(users.mac).exec(tokenId, TOKEN1, itemId);

		expect.sell().from(users.mac).exec(TOKEN1, itemId, .1 ether);
	}
}
