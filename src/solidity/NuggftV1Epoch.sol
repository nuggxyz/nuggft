// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import {INuggftV1Lens} from "@nuggft-v1-core/src/interfaces/INuggftV1.sol";

import {NuggftV1Globals} from "@nuggft-v1-core/src/common/NuggftV1Globals.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Epoch is NuggftV1Globals {
	/// @inheritdoc INuggftV1Lens
	function epoch() public view virtual override(INuggftV1Lens) returns (uint24 res) {
		res = toEpoch(block.number, genesis);
	}

	/// @notice calculates a random-enough seed that will stay the same for INTERVAL number of blocks
	function calculateSeed(uint24 _epoch) internal view returns (uint256 res) {
		// unchecked {
		uint256 startblock = toStartBlock(_epoch, genesis);

		bytes32 bhash = getBlockHash(startblock - INTERVAL_SUB);

		if (bhash == 0) _panic(Error__0x98__BlockHashIsZero);

		return uint256(keccak256(abi.encodePacked(bhash)));
		// }
	}

	function calculateSeed() internal view returns (uint256 res, uint24 _epoch) {
		_epoch = epoch();
		res = calculateSeed(_epoch);
	}

	function tryCalculateSeed(uint24 _epoch) internal view returns (uint256 res) {
		res = calculateSeed(_epoch);
	}

	// this function is nessesary to overwrite the blockhash in testing environments where it
	// either equals zero or does not change
	function getBlockHash(uint256 blocknum) internal view virtual returns (bytes32 res) {
		return blockhash(blocknum);
	}

	function toStartBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
		res = ((_epoch - OFFSET) * INTERVAL) + gen;
	}

	function toEpoch(uint256 blocknum, uint256 gen) internal pure returns (uint24 res) {
		res = uint24((blocknum - gen) / INTERVAL) + OFFSET;
	}

	function toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
		res = toStartBlock(_epoch + 1, gen) - 1;
	}
}
