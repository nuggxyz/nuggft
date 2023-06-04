// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__offer__0xA3 is NuggftV1Test {
	function test__revert__offer__0xA3__fail__desc() public {
		uint24 token1 = mintable(333);

		(uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

		mintHelper(token1, users.charlie, 1.1 ether);

		expect.sell().from(users.charlie).exec(token1, 1.2 ether);

		expect.offer().from(users.mac).value(1.3 ether).exec(token1);

		uint96 value = floor + 1 ether;

		expect.offer().err(0xA3).from(users.mac).exec{value: value}(token1, tokenId, itemId);
	}

	function test__revert__offer__0xA3__pass__desc() public {
		uint24 token1 = mintable(333);

		jumpStart();

		(uint24 tokenId, , uint16 itemId, uint96 floor) = scenario_dee_has_sold_an_item();

		mintHelper(token1, users.charlie, 1.1 ether);

		expect.sell().from(users.charlie).exec(token1, 1.2 ether);

		expect.offer().from(users.mac).value(1.3 ether).exec(token1);

		jumpSwap();

		expect.claim().from(users.mac).exec(array.b24(token1), lib.sarrAddress(users.mac));

		uint96 value = floor + 1 ether;

		expect.offer().from(users.mac).exec{value: value}(token1, tokenId, itemId);
	}
}
