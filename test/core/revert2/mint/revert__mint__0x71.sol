// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

abstract contract revert__mint__0x71 is NuggftV1Test {
	function test__revert__mint__0x71__fail__desc() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		mintHelper(TOKEN1, users.frank, 1 ether);
		mintHelper(TOKEN2, users.frank, 0, 0x68);
	}

	function test__revert__mint__0x71__pass__desc() public {
		uint24 TOKEN1 = mintable(0);
		uint24 TOKEN2 = mintable(1);
		mintHelper(TOKEN1, users.frank, 1 ether);

		mintHelper(TOKEN2, users.frank, nuggft.msp());
	}
}
