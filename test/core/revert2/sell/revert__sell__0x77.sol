// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__sell__0x77 is NuggftV1Test {
	function test__revert__sell__0x77__fail__desc() public {
		uint24 token1 = mintable(222);

		// mint
		mintHelper(token1, users.frank, 1 ether);

		expect.sell().from(users.frank).exec(token1, 2 ether);

		expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

		expect.sell().from(users.dee).err(0x77).exec(token1, 3 ether);

		// bid

		jumpStart();

		uint24 tokenId = nuggft.epoch();

		expect.offer().from(users.dee).value(nuggft.vfo(users.dee, tokenId)).exec(tokenId);

		expect.sell().from(users.dee).err(0x77).exec(tokenId, 3.5 ether);

		jumpUp(1);

		expect.sell().from(users.dee).err(0x77).exec(tokenId, 3.5 ether);
	}

	function test__revert__sell__0x77__pass__desc() public {
		uint24 token1 = mintable(222);

		jumpStart();
		// mint
		mintHelper(token1, users.frank, 1 ether);

		expect.sell().from(users.frank).exec(token1, 2 ether);

		expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

		jumpSwap();

		expect.claim().from(users.dee).exec(array.b24(token1), lib.sarrAddress(users.dee));

		expect.sell().from(users.dee).exec(token1, 3 ether);

		// bid

		jumpUp(1);

		uint24 token2 = nuggft.epoch();

		expect.offer().from(users.dee).value(3.2 ether).exec(token2);

		jumpSwap();

		expect.claim().from(users.dee).exec(array.b24(token2), lib.sarrAddress(users.dee));

		expect.sell().from(users.dee).exec(token2, 3.5 ether);
	}

	function test__revert__sell__0x77__fail__0x67() public {
		uint24 token1 = mintable(222);

		jumpStart();
		// mint
		mintHelper(token1, users.frank, 1 ether);

		expect.sell().from(users.frank).exec(token1, 2 ether);

		expect.offer().from(users.dee).value(nuggft.vfo(users.dee, token1)).exec(token1);

		jumpSwap();

		expect.claim().from(users.dee).exec(array.b24(token1), lib.sarrAddress(users.dee));

		expect.sell().from(users.dee).exec(token1, 3 ether);

		// bid

		jumpUp(1);

		uint24 token2 = nuggft.epoch();

		expect.offer().from(users.dee).value(3.2 ether).exec(token2);

		jumpUp(1);

		expect.claim().err(0x67).from(users.dee).exec(array.b24(token2), lib.sarrAddress(users.dee));
	}
}
