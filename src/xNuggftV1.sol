// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {IxNuggftV1} from "./interfaces/IxNuggftV1.sol";
import {DotnuggV1Lib} from "git.nugg.xyz/dotnugg/src/DotnuggV1Lib.sol";
import {IDotnuggV1} from "git.nugg.xyz/dotnugg/src/IDotnuggV1.sol";

import {IERC165} from "./interfaces/IERC165.sol";

import {INuggftV1} from "./interfaces/INuggftV1.sol";
import {NuggftV1Constants} from "./common/NuggftV1Constants.sol";

// 5 - 14
// 6 - 16
// 7 - 18
// 0000000000000000000000000000000000000000000000000000000000000040
// 0000000000000000000000000000000000000000000000000000000000000120
// 0000000000000000000000000000000000000000000000000000000000000006
// 0000000000000000000000000000000000000000000000000000000000000012
// 0000000000000000000000000000000000000000000000000000000000001776
// 0000000000000000000000000000000000000000000000000000000000000bee
// 0000000000000000000000000000000000000000000000000000000000000bf7
// 0000000000000000000000000000000000000000000000000000000000000829
// 0000000000000000000000000000000000000000000000000000000000000404
// 0000000000000000000000000000000000000000000000000000000000000006
// 0000000000000000000000000000000000000000000000000000000000000001
// 0000000000000000000000000000000000000000000000000000000000000001
// 0000000000000000000000000000000000000000000000000000000000000001
// 0000000000000000000000000000000000000000000000000000000000000001
// 0000000000000000000000000000000000000000000000000000000000000001
// 0000000000000000000000000000000000000000000000000000000000000001

// 0000000000000000000000000000000000000000000000000000000000001772
// 00000000000000000000000000000000000000000000000000000000000000c0
// 0000000000000000000000000000000000000000000000000000000000000003
// 0000000000000000000000000000000000000000000000000000000000000001

/// @author nugg.xyz - danny7even and dub6ix - 2022
contract xNuggftV1 is IxNuggftV1, NuggftV1Constants {
	using DotnuggV1Lib for IDotnuggV1;

	INuggftV1 immutable nuggftv1;

	constructor() {
		nuggftv1 = INuggftV1(msg.sender);
	}

	/// @inheritdoc IxNuggftV1
	function imageURI(uint256 tokenId) public view override returns (string memory res) {
		(uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
		res = nuggftv1.dotnuggv1().exec(feature, position, true);
	}

	/// @inheritdoc IxNuggftV1
	function imageSVG(uint256 tokenId) public view override returns (string memory res) {
		(uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
		res = nuggftv1.dotnuggv1().exec(feature, position, false);
	}

	function transfer(
		bytes32 proof,
		bytes32 from,
		bytes32 to
	) external payable {
		address nuggft = address(nuggftv1);

		require(msg.sender == nuggft);

		unchecked {
			assembly {
				let nugg := shr(160, from)

				let tonuggft := 0

				if eq(to, nuggft) {
					tonuggft := 1
				}

				let a := xor(shl(96, nugg), shl(88, tonuggft))

				if iszero(shr(16, proof)) {
					mstore(0x00, proof)
					mstore(0x20, 1)

					log4(0x00, 0x40, Event_TransferSingle, a, from, to)
					return(0x00, 0x00)
				}

				let ptr := mload(0x40)

				mstore(ptr, 0x40)

				let offset := add(ptr, 0x60)

				for {
					let z := proof
					let g := and(z, 0xffff)
				} iszero(eq(z, 0)) {
					z := shr(16, z)
					g := and(z, 0xffff)
				} {
					if iszero(eq(g, 0)) {
						mstore(offset, g)
						offset := add(offset, 0x20)
					}
				}

				let count := div(sub(sub(offset, 0x60), ptr), 0x20)

				mstore(add(ptr, 0x40), count)
				mstore(offset, count)
				mstore(add(ptr, 0x20), sub(offset, ptr))

				offset := add(offset, 0x20)

				for {
					let i := 0
				} lt(i, count) {
					i := add(i, 1)
				} {
					mstore(offset, 1)
					offset := add(offset, 0x20)
				}

				from := shr(96, shl(96, from))
				to := shr(96, shl(96, to))

				log4(ptr, sub(offset, ptr), Event_TransferBatch, a, from, to)
				return(0x00, 0x00)
			}
		}
	}

	function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
		return
			interfaceId == 0xd9b67a26 || //
			interfaceId == 0x0e89341c ||
			interfaceId == type(IERC165).interfaceId;
	}

	function name() public pure returns (string memory) {
		return "Nugg Fungible Items V1";
	}

	function symbol() public pure returns (string memory) {
		return "xNUGGFT";
	}

	function features() public pure returns (string[8] memory) {
		return ["base", "eyes", "mouth", "head", "back", "flag", "tail", "hold"];
	}

	function uri(uint256 tokenId) public view virtual override returns (string memory res) {
		// prettier-ignore
		res = string(
            nuggftv1.dotnuggv1().encodeJson(
                abi.encodePacked(
                     '{"name":"',         name(),
                    '","description":"',  DotnuggV1Lib.itemIdToString(uint16(tokenId), features()),
                    '","image":"',        imageURI(tokenId),
                    '"}'
                ), true
            )
        );
	}

	function totalSupply() public view returns (uint256 res) {
		for (uint8 i = 0; i < 8; i++) res += featureSupply(i);
	}

	function featureSupply(uint8 feature) public view override returns (uint256 res) {
		res = nuggftv1.dotnuggv1().lengthOf(feature);
	}

	function rarity(uint256 tokenId) public view returns (uint16 res) {
		(uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
		res = nuggftv1.dotnuggv1().rarity(feature, position);
	}

	function balanceOf(address _owner, uint256 _id) public view override returns (uint256 res) {
		uint24[] memory tokens = nuggftv1.tokensOf(_owner);

		for (uint24 i = 0; i < tokens.length; i++) {
			uint256 proof = nuggftv1.proofOf(tokens[i]);
			do {
				if (uint16(proof) == _id) res++;
				proof >>= 16;
			} while (proof != 0);
		}
	}

	function balanceOfBatch(address[] calldata _owners, uint256[] memory _ids) external view override returns (uint256[] memory) {
		for (uint256 i = 0; i < _owners.length; i++) {
			_ids[i] = balanceOf(_owners[i], _ids[i]);
		}

		return _ids;
	}

	function isApprovedForAll(address, address) external pure override returns (bool) {
		return false;
	}

	function safeTransferFrom(
		address _from,
		address _to,
		uint256 _id,
		uint256 _value,
		bytes calldata _data
	) public {}

	function safeBatchTransferFrom(
		address _from,
		address _to,
		uint256[] calldata _ids,
		uint256[] calldata _values,
		bytes calldata _data
	) external {}

	function setApprovalForAll(address, bool) external pure {
		revert("whut");
	}

	function floop(uint24 tokenId) public view returns (uint16[16] memory arr) {
		return DotnuggV1Lib.decodeProof(nuggftv1.proofOf(tokenId));
	}

	function ploop(uint24 tokenId) public view returns (string memory) {
		return DotnuggV1Lib.props(floop(tokenId), features());
	}

	function eloop() external view override returns (bytes memory res) {
		uint256 early = nuggftv1.early();

		(uint24 min, uint24 max) = nuggftv1.premintTokens();

		uint256 seed = nuggftv1.earlySeed();

		uint256 ptr;

		uint256 inc = 160 / 8;

		res = new bytes(early * inc);

		// @solidity memory-safe-assembly
		assembly {
			ptr := add(res, 32)
		}

		uint256 working;

		for (uint24 i = min; i <= max; i++) {
			working = nuggftv1.proofFromSeed(uint256(keccak256(abi.encodePacked(i, seed))));

			// @solidity memory-safe-assembly
			assembly {
				mstore(ptr, shl(96, working))
				ptr := add(ptr, inc)
			}
		}
	}

	function iloop() external view override returns (bytes memory res) {
		uint256 ptr;

		res = new bytes(256 * 8);

		assembly {
			ptr := add(res, 32)
		}

		for (uint8 i = 0; i < 8; i++) {
			uint8 len = nuggftv1.dotnuggv1().lengthOf(i) + 1;
			for (uint8 j = 1; j < len; j++) {
				uint16 item = DotnuggV1Lib.encodeItemId(i, j);
				// @solidity memory-safe-assembly
				assembly {
					mstore8(ptr, shr(8, item))
					mstore8(add(ptr, 1), item)
					ptr := add(ptr, 2)
				}
			}
		}

		assembly {
			mstore(res, sub(sub(ptr, res), 32))
		}
	}

	function tloop() external view override returns (bytes memory res) {
		uint24 epoch = nuggftv1.epoch();
		uint256 ptr;

		res = new bytes(24 * 100000);

		assembly {
			ptr := add(res, 32)
		}

		for (uint24 i = 1; i <= epoch; i++)
			if (0 != nuggftv1.agencyOf(i)) {
				// @solidity memory-safe-assembly
				assembly {
					mstore8(ptr, shr(16, i))
					mstore8(add(ptr, 1), shr(8, i))
					mstore8(add(ptr, 2), i)
					ptr := add(ptr, 3)
				}
			}

		(uint24 start, uint24 end) = nuggftv1.premintTokens();

		for (uint24 i = start; i <= end; i++)
			if (0 != nuggftv1.agencyOf(i)) {
				// @solidity memory-safe-assembly
				assembly {
					mstore8(ptr, shr(16, i))
					mstore8(add(ptr, 1), shr(8, i))
					mstore8(add(ptr, 2), i)
					ptr := add(ptr, 3)
				}
			}

		assembly {
			mstore(res, sub(sub(ptr, res), 32))
		}
	}

	function sloop() external view override returns (bytes memory res) {
		unchecked {
			uint24 epoch = nuggftv1.epoch();
			uint256 working;
			uint256 ptr;

			res = new bytes(37 * 10000);

			// @solidity memory-safe-assembly
			assembly {
				ptr := add(res, 32)
			}

			working = nuggftv1.agencyOf(epoch);

			assembly {
				mstore(add(ptr, 5), epoch)
				mstore(ptr, working)
				ptr := add(ptr, 37)
			}

			for (uint24 i = 0; i < epoch; i++) {
				working = nuggftv1.agency(i);
				if (validAgency(working, epoch)) {
					// @solidity memory-safe-assembly
					assembly {
						mstore(add(ptr, 5), i)
						mstore(ptr, working)
						ptr := add(ptr, 37)
					}
				}
			}

			(uint24 start, uint24 end) = nuggftv1.premintTokens();

			for (uint24 i = start; i <= end; i++) {
				working = nuggftv1.agencyOf(i);
				if (validAgency(working, epoch)) {
					// @solidity memory-safe-assembly
					assembly {
						mstore(add(ptr, 5), i)
						mstore(ptr, working)
						ptr := add(ptr, 37)
					}
					if (nuggftv1.agency(i) == 0) {
						uint40 token = uint40(i) | (uint40(nuggftv1.proofOf(i) >> 0x90) << 24);
						working = nuggftv1.itemAgencyOf(i, uint16(token >> 24));
						assembly {
							mstore(add(ptr, 5), token)
							mstore(ptr, working)
							ptr := add(ptr, 37)
						}
					}
				}
			}

			for (uint8 i = 0; i < 8; i++) {
				uint8 num = DotnuggV1Lib.lengthOf(nuggftv1.dotnuggv1(), i);
				for (uint8 j = 1; j <= num; j++) {
					uint16 item = (uint16(i) * 1000) + j;
					uint256 checker = nuggftv1.lastItemSwap(item);
					for (uint8 z = 0; z < 2; z++) {
						if ((working = (checker >> (z * 24)) & 0xffffff) != 0) {
							uint40 token = (uint40(item) << 24) + uint40(working);
							working = nuggftv1.itemAgencyOf(uint24(working), item);
							if (validAgency(working, epoch)) {
								// @solidity memory-safe-assembly
								assembly {
									mstore(add(ptr, 5), token)
									mstore(ptr, working)
									ptr := add(ptr, 37)
								}
							}
						}
					}
				}
			}
			// @solidity memory-safe-assembly
			assembly {
				mstore(res, sub(sub(ptr, res), 32))
			}
		}
	}

	function validAgency(uint256 _agency, uint24 epoch) internal pure returns (bool) {
		return _agency >> AFJR == 0x3 && (uint24(_agency >> AEJR) >= epoch || uint24(_agency >> AEJR) == 0);
	}
}
