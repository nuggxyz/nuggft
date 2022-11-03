// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__loan__0xA1 is NuggftV1Test {
	function test__revert__loan__0xA1__fail__desc() public {
		uint24 TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.mac).err(0xA1).exec(array.b24(TOKEN1));
	}

	function test__revert__loan__0xA1__pass__desc() public {
		uint24 TOKEN1 = mintable(0);

		mintHelper(TOKEN1, users.frank, 1 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));
	}
}
