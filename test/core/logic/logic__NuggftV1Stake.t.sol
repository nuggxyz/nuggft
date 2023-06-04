// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "git.nugg.xyz/nuggft/test/main.sol";

import {NuggftV1StakeType} from "../../helpers/NuggftV1StakeType.sol";
import {NuggftV1Loan} from "git.nugg.xyz/nuggft/src/core/NuggftV1Loan.sol";

abstract contract logic__NuggftV1Stake is NuggftV1Test {
	using NuggftV1StakeType for uint256;

	// function unsafe__addStaked(
	//     uint256 cache,
	//     uint96 protocolFee,
	//     uint96 value
	// ) public pure returns (uint256) {
	//     assembly {
	//         cache := or(and(cache, not(shl(96, sub(shl(96, 1), 1)))), shl(96, add(shr(96, cache), sub(value, protocolFee))))
	//     }

	//     return cache;
	// }

	// function safe__addStakedEth(unintcache, uint96 eth) internal returns (uint256) {
	//     // require(msg.value >= eth, hex'72'); // "value of tx too low"

	//     uint256 cache;

	//     // assembly {
	//     //     cache := sload(stake.slot)

	//     //     let pro := div(mul(eth, PROTOCOL_FEE_FRAC), 10000)

	//     //     cache := add(and(shr(96, cache), sub(shl(96, 1), 1)), sub(eth, pro))

	//     //     sstore(stake.slot, cache)
	//     // }

	//     uint96 protocolFee = (eth) / 100;

	//     unchecked {
	//         cache = cache.addStaked(eth - protocolFee);
	//     }
	//     cache = cache.addProto(protocolFee);

	//     return cache;

	//     // emit Stake(bytes32(cache));
	// }

	// function test__logic__NuggftV1Stake__symbolic__addStaked(uint256 cache, uint96 value) public {
	//     uint96 protocolFee;
	//     assembly {
	//         protocolFee := div(mul(value, 1000), 10000)
	//     }
	//     uint256 unsafe = unsafe__addStaked(cache, protocolFee, value);
	//     uint256 safe = cache.addStaked(value - protocolFee);

	//     assertEq(unsafe, safe, 'A');
	// }
}
