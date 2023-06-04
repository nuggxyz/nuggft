// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__mint__0x65 is NuggftV1Test {
	function test__revert__mint__0x65__fail__desc() public {
		mintHelper(mintable(0) - 1, users.frank, nuggft.vfo(users.frank, mintable(0)), 0x65);

		// expect.mint().from(users.frank).err(0x65).exec(uint32(MAX_TOKENS) + 1);
	}

	function test__revert__mint__0x65__pass__desc() public {
		mintHelper(mintable(0), users.frank, nuggft.vfo(users.frank, mintable(0)));

		mintHelper(mintable(1000), users.frank, nuggft.vfo(users.frank, mintable(1000)));
	}
}
