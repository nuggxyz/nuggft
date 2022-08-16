// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__offer__0x71 is NuggftV1Test {
	function test__revert__offer__0x71__fail__desc() public {
		uint24 TOKEN1 = mintable(1);

		jumpStart();

		mintHelper(TOKEN1, users.frank, 1 ether);
		uint24 tokenId = nuggft.epoch();

		// jump(tokenId);

		uint96 msp = nuggft.msp();

		expect.offer().from(users.frank).value(msp - 10 gwei).err(0x71).exec(tokenId);
	}

	function test__revert__offer__0x71__pass__desc() public {
		uint24 TOKEN1 = mintable(0);

		jumpStart();

		mintHelper(TOKEN1, users.frank, 1 ether);
		uint24 tokenId = nuggft.epoch();

		// jump(tokenId);

		uint96 msp = nuggft.msp();

		expect.offer().from(users.frank).value(msp).exec(tokenId);
	}
}
