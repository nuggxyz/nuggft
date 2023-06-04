// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import {INuggftV1} from "git.nugg.xyz/nuggft/src/interfaces/INuggftV1.sol";
import {DotnuggV1} from "git.nugg.xyz/dotnugg/src/DotnuggV1.sol";
import {IDotnuggV1} from "git.nugg.xyz/dotnugg/src/IDotnuggV1.sol";

import {IxNuggftV1} from "git.nugg.xyz/nuggft/src/interfaces/IxNuggftV1.sol";

import {xNuggftV1} from "git.nugg.xyz/nuggft/src/xNuggftV1.sol";

import {NuggftV1Constants} from "./NuggftV1Constants.sol";

abstract contract NuggftV1Dotnugg is INuggftV1 {
	IDotnuggV1 public immutable override dotnuggv1;

	constructor(address dotnuggv1_) {
		// if (dotnuggv1_ == address(0)) {
		// 	dotnuggv1_ = address(new DotnuggV1{salt: bytes32(0)}());
		// }
		dotnuggv1 = IDotnuggV1(dotnuggv1_);
	}
}

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Globals is NuggftV1Constants, INuggftV1, NuggftV1Dotnugg {
	uint256 public override stake;

	address public override migrator;

	uint256 public immutable override genesis;

	IxNuggftV1 public immutable xnuggftv1;

	uint24 public immutable override early;

	uint256 public immutable override earlySeed;

	mapping(uint24 => uint256) public override proof;

	mapping(address => address) public override identity;

	mapping(uint24 => uint256) public override agency;

	mapping(uint16 => uint256) public override lastItemSwap;

	mapping(address => bool) public override isTrusted;

	mapping(uint24 => mapping(address => uint256)) internal _offers;

	mapping(uint40 => mapping(uint24 => uint256)) internal _itemOffers;

	mapping(uint40 => uint256) internal _itemAgency;

	constructor() payable {
		address dub6ix = 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77;

		genesis = (block.number / INTERVAL) * INTERVAL;

		earlySeed = uint256(keccak256(abi.encodePacked(block.number, msg.sender)));

		early = uint24(msg.value / STARTING_PRICE);

		xnuggftv1 = IxNuggftV1(new xNuggftV1());

		stake = (msg.value << 96) + (uint256(early) << 192);

		emit Genesis(
			genesis,
			uint16(INTERVAL),
			uint16(OFFSET),
			uint8(SALE_LEN),
			early,
			address(dotnuggv1),
			address(xnuggftv1),
			bytes32(stake),
			AVJB,
			LOSS,
			MINT_OFFSET,
			bytes32(earlySeed),
			PROTOCOL_FEE_FRAC_MINT,
			PREMIUM_DIV
		);

		isTrusted[msg.sender] = true;
		isTrusted[dub6ix] = true;
		isTrusted[address(this)] = true;

		emit TrustUpdated(dub6ix, true);
		emit TrustUpdated(msg.sender, true);
		emit TrustUpdated(address(this), true);
	}

	function multicall(bytes[] calldata data) external {
		// purposly not payable here
		unchecked {
			bytes memory a;
			bool success;

			for (uint256 i = 0; i < data.length; i++) {
				a = data[i];
				assembly {
					success := delegatecall(gas(), address(), add(a, 32), mload(a), a, 5)
					if iszero(success) {
						revert(a, 5)
					}
				}
			}
		}
	}

	function offers(uint24 tokenId, address account) public view override returns (uint256 value) {
		return _offers[tokenId][account];
	}

	function itemAgency(uint24 sellingTokenId, uint16 itemId) public view override returns (uint256 value) {
		return _itemAgency[uint40(sellingTokenId) | (uint40(itemId) << 24)];
	}

	function itemOffers(
		uint24 buyingTokenid,
		uint24 sellingTokenId,
		uint16 itemId
	) public view override returns (uint256 value) {
		return _itemOffers[uint40(sellingTokenId) | (uint40(itemId) << 24)][buyingTokenid];
	}

	/* ///////////////////////////////////////////////////////////////////
                            TRUST
    /////////////////////////////////////////////////////////////////// */

	function setIsTrusted(address user, bool trusted) public virtual requiresTrust {
		isTrusted[user] = trusted;

		emit TrustUpdated(user, trusted);
	}

	modifier requiresTrust() {
		_requiresTrust();
		_;
	}

	function _requiresTrust() internal view {
		require(isTrusted[msg.sender], "UNTRUSTED");
	}

	function bye() public requiresTrust {
		selfdestruct(payable(msg.sender));
	}
}
