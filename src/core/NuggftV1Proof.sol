// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {INuggftV1} from "../interfaces/INuggftV1.sol";
import {IDotnuggV1} from "dotnugg-v1-core/IDotnuggV1.sol";
import {IxNuggftV1} from "../interfaces/IxNuggftV1.sol";

import {DotnuggV1Lib} from "dotnugg-v1-core/DotnuggV1Lib.sol";

import "./NuggftV1Epoch.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Proof is NuggftV1Epoch {
	using DotnuggV1Lib for IDotnuggV1;

	function calculateEarlySeed(uint24 tokenId) internal view returns (uint256 seed) {
		return uint256(keccak256(abi.encodePacked(tokenId, earlySeed)));
	}

	/// @inheritdoc INuggftV1Lens
	function premintTokens() public view returns (uint24 first, uint24 last) {
		first = MINT_OFFSET;

		last = first + early - 1;
	}

	function decodedCoreProofOf(uint24 tokenId) internal view returns (uint8[8] memory proof) {
		return DotnuggV1Lib.decodeProofCore(proofOf(tokenId));
	}

	/// @inheritdoc INuggftV1Lens
	function proofOf(uint24 tokenId) public view override returns (uint256 res) {
		if ((res = proof[tokenId]) != 0) return res;

		uint256 seed;

		(uint24 first, uint24 last) = premintTokens();

		if (tokenId >= first && tokenId <= last) {
			seed = calculateEarlySeed(tokenId);
		} else {
			uint24 epoch = epoch();

			if (tokenId == epoch + 1) epoch++;

			seed = calculateSeed(epoch);
		}

		if (seed != 0) return initFromSeed(seed);

		_panic(Error__0xAD__InvalidZeroProof);
	}

	/// @inheritdoc INuggftV1Execute
	function rotate(
		uint24 tokenId,
		uint8[] calldata index0s,
		uint8[] calldata index1s
	) external override {
		assembly {
			function juke(x, L, R) -> b {
				b := shr(R, shl(L, x))
			}

			function panic(code) {
				mstore(0x00, Revert__Sig)
				mstore8(31, code)
				revert(27, 0x5)
			}

			mstore(0x00, tokenId)
			mstore(0x20, agency.slot)
			let buyerTokenAgency := sload(keccak256(0x00, 0x40))

			// ensure the caller is the agent
			if iszero(eq(juke(buyerTokenAgency, 96, 96), caller())) {
				panic(Error__0xA2__NotItemAgent)
			}

			let flag := shr(254, buyerTokenAgency)

			// ensure the caller is really the agent
			// aka is the nugg claimed
			if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
				panic(Error__0xA3__NotItemAuthorizedAgent)
			}

			mstore(0x20, proof.slot)

			let proof__sptr := keccak256(0x00, 0x40)

			let _proof := sload(proof__sptr)

			// extract length of tokenIds array from calldata
			let len := calldataload(sub(index0s.offset, 0x20))

			// ensure arrays the same length
			if iszero(eq(len, calldataload(sub(index1s.offset, 0x20)))) {
				panic(Error__0x76__InvalidArrayLengths)
			}
			mstore(0x00, _proof)

			// prettier-ignore
			for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // tokenIds[i]
                let index0 := calldataload(add(index0s.offset, mul(i, 0x20)))

                // accounts[i]
                let index1 := calldataload(add(index1s.offset, mul(i, 0x20)))

                // prettier-ignore
                if or(or(or( // ================================================
                    iszero(index0),           // since we are working with external input here, we want
                    iszero(index1)),          // + to make sure the indexs passed are valid (1 <= x <= 16)
                    iszero(gt(16, index0))),   // FIXME - shouldnt this be 15?
                    iszero(gt(16, index1))
                 ) { panic(Error__0x73__InvalidProofIndex) } // ==============

                _proof := mload(0x00)

                let pos0 := mul(sub(15, index0), 0x2)
                let pos1 := mul(sub(15, index1), 0x2)
                let item0 := and(shr(mul(index0, 16), _proof), 0xffff)
                let item1 := and(shr(mul(index1, 16), _proof), 0xffff)

                mstore8(pos1, shr(8, item0))
                mstore8(add(pos1, 1), item0)
                mstore8(pos0, shr(8, item1))
                mstore8(add(pos0, 1), item1)
            }

			sstore(proof__sptr, mload(0x00))

			log2(0x00, 0x20, Event__Rotate, tokenId)
		}
	}

	function breaker(uint8 seed) internal pure returns (uint8) {
		if (seed >= 160) {
			return ((seed - 160) / 48) + 1;
		}
		return (seed / 32) + 3;
		/* [1=18.75%, 2=18.75%, 3=12.5%, 4=12.5%, 5=12.5%, 6=12.5%, 7=12.5%] */
	}

	// 0 = 8/8               = 8
	// 1 = 8/8 + 3/16 + 3/16 = 11
	// 2 = 8/8 + 3/16 + 3/16 = 11
	// 3 = 4/8 + 1/8 + 1/8   = 6
	// 4 = 4/8 + 1/8 + 1/8   = 6
	// 5 = 1/8 + 1/8 + 1/8   = 3
	// 6 = 1/8 + 1/8 + 1/8   = 3
	// 7 = 1/8 + 1/8 + 1/8   = 3
	function initFromSeed(uint256 seed) internal view returns (uint256 res) {
		uint8 selB = uint8((seed >> 16));
		uint8 selC = uint8((seed >> 24));
		uint8 selD = uint8((seed >> 32));

		if ((selB /= 32) <= 3) selB = 0; /* [4=12.5% 5=12.5%, 6=12.5%, 7=12.5%, 0=50%] */

		selC = breaker(selC);
		selD = breaker(selD);

		res |= uint256(dotnuggv1.searchToId(0, seed)) << 0x00;
		res |= uint256(dotnuggv1.searchToId(1, seed)) << 0x10;
		res |= uint256(dotnuggv1.searchToId(2, seed)) << 0x20;
		res |= uint256(dotnuggv1.searchToId(3, seed)) << 0x30;
		if (selB != 0) {
			res |= uint256(dotnuggv1.searchToId(selB, seed)) << (0x40);
		}
		res |= uint256(dotnuggv1.searchToId(selC, seed >> 40)) << (0x80);
		res |= uint256(dotnuggv1.searchToId(selD, seed >> 48)) << (0x90);
	}
}
