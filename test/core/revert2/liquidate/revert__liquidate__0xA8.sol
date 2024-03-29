// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

abstract contract revert__liquidate__0xA8 is NuggftV1Test {
	uint24 private TOKEN1;

	function test__revert__liquidate__0xA8__fail__desc() public {
		TOKEN1 = mintable(0);
		mintHelper(TOKEN1, users.frank, .5 ether);

		// expec called debt() which performed this check earlier than desired
		forge.vm.deal(users.frank, 900 ether);
		forge.vm.prank(users.frank);
		forge.vm.expectRevert(hex"7e863b48_A8");
		nuggft.liquidate{value: 1 ether}(TOKEN1);
	}

	function test__revert__liquidate__0xA8__pass__desc() public {
		TOKEN1 = mintable(0);
		mintHelper(TOKEN1, users.frank, .5 ether);

		expect.loan().from(users.frank).exec(array.b24(TOKEN1));

		expect.liquidate().from(users.frank).value(1 ether).exec(TOKEN1);
	}
}
