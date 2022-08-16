// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__offer__0x72 is NuggftV1Test {
	function test__revert__offer__0x72__fail__desc() public {
		jumpStart();

		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.mac).value(1 ether).exec(tokenId);

		uint96 next = nuggft.vfo(users.frank, tokenId);

		expect.offer().from(users.frank).value(next - 10 gwei).err(0x72).exec(tokenId);
	}

	function test__revert__offer__0x72__pass__desc() public {
		jumpStart();

		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.mac).value(1 ether).exec(tokenId);

		uint96 next = nuggft.vfo(users.frank, tokenId);

		expect.offer().from(users.frank).value(next).exec(tokenId);
	}
}
