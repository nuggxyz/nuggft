// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract txgas__NuggftV1Stake is NuggftV1Test {
	function setUp() public {
		reset();

		forge.vm.deal(users.frank, 40000 ether);

		mintHelper(mintable(1199), users.frank, 100 ether);

		mintHelper(mintable(1200), users.frank, nuggft.msp());

		jumpStart();

		mintHelper(mintable(1201), users.frank, nuggft.msp());
	}

	function test__txgas__NuggftV1Stake__addStakedEth() public {
		mintHelper(mintable(1202), users.frank, nuggft.msp());
	}
}
