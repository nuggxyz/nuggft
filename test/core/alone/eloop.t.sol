// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "@nuggft-v1-core/test/main.sol";

contract eloop__offer is NuggftV1Test {
	function setUp() public {
		reset();
	}

	function test__1() public {
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

			uint256 working = nuggft.proofFromSeed(uint256(keccak256(abi.encodePacked(seed, i))));
			uint256 check;

			assembly {
				check := shr(96, mload(ptr))
			}

			ds.assertEq(check, working);

			// @solidity memory-safe-assembly
			assembly {
				ptr := add(ptr, inc)
			}
		}

		ds.assertEq(count, early);
	}
}
