// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "@nuggft-v1-core/test/main.sol";

contract eloop__offer is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__eloop__fromSeed() public {
		uint256 seed = nuggft.earlySeed();

		uint24 i = 1000888;

		uint256 seeded = nuggft.proofFromSeed(uint256(keccak256(abi.encodePacked(i, seed))));

		uint256 working = nuggft.proofOf(i);

		ds.assertEq(bytes32(seeded), bytes32(working));
	}

	function test__eloop_a() public {
		bytes memory loop = xnuggft.eloop();

		uint256 early = nuggft.early();

		(uint24 min, uint24 max) = nuggft.premintTokens();

		uint256 seed = nuggft.earlySeed();

		uint256 ptr;

		uint256 inc = 160 / 8;

		// @solidity memory-safe-assembly
		assembly {
			ptr := add(loop, 32)
		}

		uint256 count;

		for (uint24 i = min; i <= max; i++) {
			count++;

			uint256 working = nuggft.proofOf(i);
			uint256 check;
			uint256 seeded = nuggft.proofFromSeed(uint256(keccak256(abi.encodePacked(i, seed))));

			assembly {
				check := shr(96, mload(ptr))
			}

			ds.assertEq(bytes32(check), bytes32(working));
			ds.assertEq(bytes32(check), bytes32(seeded));

			// @solidity memory-safe-assembly
			assembly {
				ptr := add(ptr, inc)
			}
		}

		ds.assertEq(bytes32(count), bytes32(early));
	}
}
