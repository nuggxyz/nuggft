// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__claim__0xA5 is NuggftV1Test {
	function test__revert__claim__0xA5__fail__desc() public {
		jumpStart();

		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId)}(tokenId);

		jumpSwap();

		expect.claim().from(users.frank).err(0xA5).exec(array.b24(tokenId), array.bAddress(users.frank));
	}

	function test__revert__claim__0xA5__pass__desc() public {
		jumpStart();

		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.dee).exec{value: nuggft.vfo(users.dee, tokenId)}(tokenId);

		jumpSwap();

		expect.claim().from(users.dee).exec(array.b24(tokenId), array.bAddress(users.dee));
	}
}
