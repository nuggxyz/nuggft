// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract general__multicall is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__multicall() public {
		uint24 token = nuggft.epoch();

		expect.offer().from(users.frank).exec{value: nuggft.msp()}(token);

		jumpSwap();

		bytes[] memory a = new bytes[](2);

		expect.claim().start(array.b24(token), array.bAddress(users.frank), new uint24[](1), new uint16[](1), users.frank);

		uint16[16] memory floopA = xnuggft.floop(token);
		a[0] = abi.encodeWithSelector(nuggft.claim.selector, array.b24(token), array.bAddress(users.frank), new uint24[](1), new uint16[](1));
		a[1] = abi.encodeWithSelector(nuggft.rotate.selector, token, array.b8(1), array.b8(9));

		forge.vm.prank(users.frank);
		nuggft.multicall(a);

		uint16[16] memory floopB = xnuggft.floop(token);

		require(floopA[1] == floopB[9] && floopA[9] == floopB[1], "floops are off");

		expect.claim().stop();
	}

	// same as above, but throws an error on claim
	function test__multicall__bubbleUpError() public {
		uint24 token = nuggft.epoch();

		expect.offer().from(users.frank).exec{value: nuggft.msp()}(token);

		jumpSwap();

		bytes[] memory a = new bytes[](2);

		expect.claim().err(0x76).start(array.b24(token), array.bAddress(users.frank), new uint24[](0), new uint16[](1), users.frank);

		a[0] = abi.encodeWithSelector(nuggft.claim.selector, array.b24(token), array.bAddress(users.frank), new uint24[](0), new uint16[](1));
		a[1] = abi.encodeWithSelector(nuggft.rotate.selector, token, array.b8(1), array.b8(9));

		forge.vm.startPrank(users.frank);
		forge.vm.expectRevert(abi.encodePacked(bytes4(0x7e863b48), bytes1(0x76)));
		nuggft.multicall(a);
		forge.vm.stopPrank();

		expect.claim().rollback();
	}
}
