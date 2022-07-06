// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {INuggftV1Lens} from "../interfaces/INuggftV1.sol";

import {NuggftV1Globals} from "./NuggftV1Globals.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Epoch is NuggftV1Globals {
	/// @inheritdoc INuggftV1Lens
	function epoch() public view virtual override returns (uint24 res) {
		res = toEpoch(block.number, genesis);
	}

	/// @notice calculates a random-enough seed that will stay the same for INTERVAL number of blocks
	function calculateSeed(uint24 _epoch) internal view returns (uint256 res) {
		unchecked {
			uint256 startblock = toStartBlock(_epoch, genesis);

			bytes32 bhash = getBlockHash(startblock - INTERVAL_SUB);
			if (bhash == 0) _panic(Error__0x98__BlockHashIsZero);

			assembly {
				mstore(0x00, bhash)
				mstore(0x20, _epoch)
				res := keccak256(0x00, 0x40)
			}
		}
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
		assembly {
			res := add(mul(sub(_epoch, OFFSET), INTERVAL), gen)
		}
	}

	function toEpoch(uint256 blocknum, uint256 gen) internal pure returns (uint24 res) {
		assembly {
			res := add(div(sub(blocknum, gen), INTERVAL), OFFSET)
		}
	}

	function toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
		unchecked {
			res = toStartBlock(_epoch + 1, gen) - 1;
		}
	}
}
