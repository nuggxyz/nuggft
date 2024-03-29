// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__sell__0x70 is NuggftV1Test {
	function test__revert__sell__0x70__fail__desc() public {
		uint24 TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		uint96 value = nuggft.eps() - 10 gwei;

		expect.sell().from(users.frank).err(0x70).exec(TOKEN1, value);
	}

	function test__revert__sell__0x70__pass__desc() public {
		uint24 TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		uint96 value = nuggft.eps();

		expect.sell().from(users.frank).exec(TOKEN1, value);
	}
}
