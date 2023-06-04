// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

contract proofOfTest is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__proofOf__pendings() public {
		jumpUp(833);

		uint24 epoch = nuggft.epoch();
		uint256 pn = nuggft.proofOf(epoch + 1);

		uint256 p0 = nuggft.proofOf(epoch);
		uint256 p1 = nuggft.proofOf(epoch - 1);
		uint256 p2 = nuggft.proofOf(epoch - 2);
		uint256 p3 = nuggft.proofOf(epoch - 3);

		ds.assertNotEq(bytes32(pn), bytes32(p0));

		ds.assertNotEq(bytes32(p0), bytes32(p1));

		ds.assertNotEq(bytes32(p1), bytes32(p2));

		ds.assertNotEq(bytes32(p2), bytes32(p3));
	}

	function test__proofOf__pendingOffers() public {
		jumpUp(833);

		uint24 epoch = nuggft.epoch();

		expect.offer().from(users.mac).exec{value: 1 ether}(epoch);
		expect.offer().from(users.mac).exec{value: 1 ether}(epoch - 1);
		expect.offer().from(users.mac).exec{value: 1 ether}(epoch - 2);
		expect.offer().from(users.mac).exec{value: 1 ether}(epoch - 3);
		uint256 pn = nuggft.proofOf(epoch + 1);
		uint256 p0 = nuggft.proofOf(epoch);
		uint256 p1 = nuggft.proofOf(epoch - 1);
		uint256 p2 = nuggft.proofOf(epoch - 2);
		uint256 p3 = nuggft.proofOf(epoch - 3);

		ds.assertNotEq(bytes32(pn), bytes32(p0));

		ds.assertNotEq(bytes32(p0), bytes32(p1));

		ds.assertNotEq(bytes32(p1), bytes32(p2));

		ds.assertNotEq(bytes32(p2), bytes32(p3));
	}
}
