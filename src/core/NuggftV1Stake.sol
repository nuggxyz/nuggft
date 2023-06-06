// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {INuggftV1, INuggftV1Lens} from "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";

import {NuggftV1Proof} from "./NuggftV1Proof.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Stake is NuggftV1Proof {
	/// @inheritdoc INuggftV1Lens
	function eps() public view override returns (uint96 res) {
		assembly {
			let cache := sload(stake.slot)
			res := shr(192, cache)
			res := div(and(shr(96, cache), sub(shl(96, 1), 1)), res)
		}
	}

	/// @inheritdoc INuggftV1Lens
	function msp() public view override returns (uint96 res) {
		(uint96 total,,,, uint96 increment) = minSharePriceBreakdown(stake);
		res = total + increment;
	}

	/// @inheritdoc INuggftV1Lens
	function shares() public view override returns (uint64 res) {
		res = uint64(stake >> 192);
	}

	/// @inheritdoc INuggftV1Lens
	function staked() public view override returns (uint96 res) {
		res = uint96(stake >> 96);
	}

	/// @inheritdoc INuggftV1Lens
	function proto() public view override returns (uint96 res) {
		res = uint96(stake);
	}

	/// @inheritdoc INuggftV1Lens
	function totalSupply() public view override returns (uint256 res) {
		res = shares();
	}

	/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
								   adders
	   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

	/// @notice handles the adding of shares - ensures enough eth is being added
	/// @dev this is the only way to add shares - the logic here ensures that "ethPerShare" can never decrease
	function addStakedShare(uint256 value) internal returns (uint256 cache) {
		assembly {
			// load stake to callstack
			cache := sload(stake.slot)

			let shrs := shr(192, cache)

			let _eps := div(shr(160, shl(64, cache)), shrs)

			let fee := div(_eps, PROTOCOL_FEE_FRAC_MINT)

			let premium := div(mul(_eps, shrs), PREMIUM_DIV)

			let _msp := add(_eps, add(fee, premium))

			_msp := div(mul(_msp, INCREMENT_BPS), BASE_BPS)

			// ensure value >= msp
			if gt(_msp, value) {
				mstore(0x00, Revert__Sig)
				mstore8(0x4, Error__0x71__ValueTooLow)
				revert(0x00, 0x5)
			}

			// caculate value proveded over msp
			// will not underflow because of ERRORx71
			let overpay := sub(value, _msp)

			// add fee of overpay to fee
			fee := add(div(overpay, PROTOCOL_FEE_FRAC_MINT_DIV), fee)
			// fee := div(value, PROTOCOL_FEE_FRAC_MINT)

			// update stake
			// =======================
			// stake = {
			//     shares  = prev + 1
			//     eth     = prev + (msg.value - fee)
			//     proto   = prev + fee
			// }
			// =======================
			cache := add(cache, or(shl(192, 1), or(shl(96, sub(value, fee)), fee)))

			sstore(stake.slot, cache)

			// mstore(0x20, cache)
		}
	}

	/// @notice handles isolated staking of eth
	/// @dev supply of eth goes up while supply of shares stays constant - increasing "minSharePrice"
	/// @param value the amount of eth being staked - must be some portion of msg.value
	function addStakedEth(uint96 value) internal {
		assembly {
			let pro := div(value, PROTOCOL_FEE_FRAC)

			let cache := add(sload(stake.slot), or(shl(96, sub(value, pro)), pro))

			sstore(stake.slot, cache)

			mstore(0x00, cache)
			log1(0x00, 0x20, Event__Stake)
		}
	}

	// @test manual
	// make sure the assembly works like regular (checked solidity)
	function minSharePriceBreakdown(uint256 cache)
		internal
		pure
		returns (uint96 total, uint96 ethPerShare, uint96 protocolFee, uint96 premium, uint96 increment)
	{
		assembly {
			let shrs := shr(192, cache)
			ethPerShare := div(and(shr(96, cache), sub(shl(96, 1), 1)), shrs)
			protocolFee := div(ethPerShare, PROTOCOL_FEE_FRAC_MINT)
			premium := div(mul(ethPerShare, shrs), PREMIUM_DIV)
			total := add(ethPerShare, add(protocolFee, premium))
			// TODO --- fix this
			increment := sub(div(mul(total, INCREMENT_BPS), BASE_BPS), total)
			// total := add(total, increment)
		}
	}

	// @test manual
	function calculateEthPerShare(uint256 cache) internal pure returns (uint96 res) {
		assembly {
			res := shr(192, cache)
			res := div(and(shr(96, cache), sub(shl(96, 1), 1)), res)
		}
	}
}
