// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {ShiftLib} from "./ShiftLib.sol";
import {CastLib} from "./CastLib.sol";

import {NuggftV1Constants} from "git.nugg.xyz/nuggft/src/common/NuggftV1Constants.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
abstract contract NuggftV1AgentType is NuggftV1Constants {
	using CastLib for uint256;

	// // 10**13
	// uint96 constant COMPRESSION_LOSS = 10e8;

	// /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	//                            CALCULATION
	//    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

	// // @test  manual
	// function addIncrement(uint96 value) internal pure returns (uint96 res) {
	// 	// res = value * 10200; -- increment can never go highter than uint96
	// 	assembly {
	// 		res := div(mul(value, 10200), 10000)
	// 	}
	// }

	// // @test  manual
	// function compressEthRoundDown(uint96 value) internal pure returns (uint96 res) {
	// 	assembly {
	// 		res := mul(div(value, COMPRESSION_LOSS), COMPRESSION_LOSS)
	// 	}
	// }

	// // @test  manual
	// function compressEthRoundUp(uint96 value) internal pure returns (uint96 res) {
	// 	assembly {
	// 		res := mod(value, COMPRESSION_LOSS)
	// 	}
	// 	if (res > 0) {
	// 		assembly {
	// 			res := mul(add(div(value, COMPRESSION_LOSS), 1), COMPRESSION_LOSS)
	// 		}
	// 	} else {
	// 		return compressEthRoundDown(value);
	// 	}
	// }

	/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                              SHIFT HELPERS
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
	// @test input output unit test
	// type(uint96).max / 10e9 =     79228162514264337593
	// type(uint69).max          =  590295810358705651712
	// function setAgencyEth(uint256 input) internal pure returns (uint96 res) {
	// 	input = ShiftLib.get(input, 70, 160);
	// 	assembly {
	// 		res := mul(input, COMPRESSION_LOSS)
	// 	}
	// 	// return input.to96();
	// }

	function setAgencyEth(uint256 input, uint96 update) internal pure returns (uint256 cache) {
		assembly {
			update := div(update, LOSS) // bye byte wei
		}
		cache = ShiftLib.set(input, AVJB, AVJO, update);
	}

	// @test  input output unit test
	function setAgencyEpoch(uint256 input, uint24 update) internal pure returns (uint256 res) {
		return ShiftLib.set(input, AEJB, AEJO, update);
	}

	function getAgencyEpoch(uint256 input) internal pure returns (uint24 res) {
		return uint24(ShiftLib.get(input, AEJB, AEJO));
	}

	// // @test  input output unit test
	// function account(uint256 input) internal pure returns (address res) {
	// 	res = address(uint160(ShiftLib.get(input, 160, 0)));
	// }

	// function account(uint256 input, address update) internal pure returns (uint256 output) {
	// 	output = ShiftLib.set(input, 160, 0, uint160(update));
	// }

	// // @test  input output unit test
	// function flag(uint256 input, Flag update) internal pure returns (uint256 res) {
	// 	return ShiftLib.set(input, 2, 254, uint8(update));
	// }

	// function flag(uint256 input) internal pure returns (Flag output) {
	// 	output = Flag(ShiftLib.get(input, 2, 254));
	// }

	// // @test  input output unit test
	// function flag2(uint256 input, bool update) internal pure returns (uint256 res) {
	//     return ShiftLib.set(input, 1, 254, update ? 0x1 : 0x0);
	// }

	// function flag2(uint256 input) internal pure returns (bool output) {
	//     output = ShiftLib.get(input, 1, 254) == 0x1;
	// }

	// @test  check to see if it does this - will be easy
	// function _mark(uint256 input) private pure returns (uint256 res) {
	//     res = ShiftLib.set(input, 1, 255, 0x01);
	// }

	enum Flag {
		NONE,
		SWAP,
		LOAN,
		OWN
	}

	// // @test  manual
	// function create(
	// 	uint24 _epoch,
	// 	address _account,
	// 	uint96 _eth,
	// 	Flag _flag
	// ) internal pure returns (uint256 res) {
	// 	res = epoch(res, _epoch);
	// 	res = account(res, _account);
	// 	res = flag(res, _flag);
	// 	res = eth(res, _eth);
	// 	// res = _mark(res);
	// }
}
