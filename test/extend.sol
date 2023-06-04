// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {DotnuggV1} from "git.nugg.xyz/dotnugg/src/DotnuggV1.sol";
import {INuggftV1, INuggftV1Lens} from "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";
import {NuggftV1} from "git.nugg.xyz/nuggft/src/NuggftV1.sol";
import {NuggftV1Epoch} from "git.nugg.xyz/nuggft/src/core/NuggftV1Epoch.sol";
import {DotnuggV1Lib} from "git.nugg.xyz/dotnugg/src/DotnuggV1Lib.sol";

interface INuggftV1Extended is INuggftV1 {
	function external__search(uint8 feature, uint256 seed) external view returns (uint8);

	function external__calculateSeed() external view returns (uint256 res, uint24 _epoch);

	function external__calculateSeed(uint24 _epoch) external view returns (uint256 res);

	function external__agency(uint24 tokenId) external view returns (uint256 res);

	function external__stake() external view returns (uint256 res);

	function external__calc(uint96 a, uint96 b) external pure returns (uint96 resa, uint96 resb);

	function external__toStartBlock(uint24 _epoch, uint32 gen) external pure returns (uint256 res);

	function external__toStartBlock(uint24 _epoch) external view returns (uint256 res);

	function external__toEndBlock(uint24 _epoch, uint32 gen) external pure returns (uint256 res);

	function external__toEpoch(uint256 blocknum, uint256 gen) external pure returns (uint256 res);

	function external__agency__slot() external pure returns (bytes32 res);

	function external__LOSS() external pure returns (uint256 res);

	function external__initFromSeed(uint256 seed) external view returns (uint256 res);

	function external__minSharePriceBreakdown()
		external
		view
		returns (
			uint96 total,
			uint96 ethPerShare,
			uint96 protocolFee,
			uint96 premium,
			uint96 increment
		);
}

contract NuggftV1Extended is NuggftV1, INuggftV1Extended {
	constructor() payable NuggftV1(address(new DotnuggV1())) {}

	function epoch() public view override(INuggftV1Lens, NuggftV1Epoch) returns (uint24 res) {
		require(block.number >= genesis, "YOU MADE A BAD ROOOLLLLLLLLLLL");
		return super.epoch();
	}

	function getBlockHash(uint256 blocknum) internal view override returns (bytes32 res) {
		if (block.number > blocknum && block.number - blocknum < 256) {
			return keccak256(abi.encodePacked(blocknum));
		}
	}

	function external__search(uint8 feature, uint256 seed) external view returns (uint8) {
		return DotnuggV1Lib.search(dotnuggv1, feature, seed);
	}

	function external__calculateSeed() external view returns (uint256 res, uint24 _epoch) {
		return calculateSeed();
	}

	function external__calculateSeed(uint24 _epoch) external view returns (uint256 res) {
		return calculateSeed(_epoch);
	}

	function external__agency(uint24 tokenId) external view returns (uint256 res) {
		return agency[tokenId];
	}

	function external__stake() external view returns (uint256 res) {
		return stake;
	}

	function external__calc(uint96 a, uint96 b) external pure returns (uint96 resa, uint96 resb) {
		return calc(a, b);
	}

	function external__toStartBlock(uint24 _epoch, uint32 gen) public pure returns (uint256 res) {
		return toStartBlock(_epoch, gen);
	}

	function external__toStartBlock(uint24 _epoch) public view returns (uint256 res) {
		return toStartBlock(_epoch, genesis);
	}

	function external__toEndBlock(uint24 _epoch, uint32 gen) public pure returns (uint256 res) {
		return toEndBlock(_epoch, gen);
	}

	function external__toEpoch(uint256 blocknum, uint256 gen) public pure returns (uint256 res) {
		return toEpoch(blocknum, gen);
	}

	function external__agency__slot() public pure returns (bytes32 res) {
		assembly {
			res := agency.slot
		}
	}

	function external__LOSS() public pure returns (uint256 res) {
		res = LOSS;
	}

	function external__initFromSeed(uint256 seed) public view returns (uint256 res) {
		return initFromSeed(seed);
	}

	function external__minSharePriceBreakdown()
		public
		view
		returns (
			uint96 total,
			uint96 ethPerShare,
			uint96 protocolFee,
			uint96 premium,
			uint96 increment
		)
	{
		return minSharePriceBreakdown(stake);
	}
}

contract NuggFatherV1Extended {
	NuggftV1Extended public nuggft;

	constructor(bytes32 salt) payable {
		nuggft = new NuggftV1Extended{value: msg.value, salt: salt}();
	}
}
