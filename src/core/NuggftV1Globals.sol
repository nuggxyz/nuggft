// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {IDotnuggV1} from "dotnugg-v1-core/IDotnuggV1.sol";
import {DotnuggV1} from "dotnugg-v1-core/DotnuggV1.sol";
import {IxNuggftV1} from "../interfaces/nuggftv1/IxNuggftV1.sol";
import {xNuggftV1} from "../xNuggftV1.sol";

import {NuggftV1Constants} from "./NuggftV1Constants.sol";
import {INuggftV1Globals} from "../interfaces/nuggftv1/INuggftV1Globals.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
abstract contract NuggftV1Globals is NuggftV1Constants, INuggftV1Globals {
    mapping(uint24 => uint256) public override proof;
    mapping(uint24 => uint256) public override agency;
    mapping(uint16 => uint256) public override lastItemSwap;

    mapping(uint24 => mapping(address => uint256)) internal _offers;
    mapping(uint40 => mapping(uint24 => uint256)) internal _itemOffers;
    mapping(uint40 => uint256) internal _itemAgency;

    uint256 public override stake;
    address public override migrator;
    uint256 public immutable override genesis;
    IDotnuggV1 public immutable override dotnuggv1;
    IxNuggftV1 public immutable xnuggftv1;
    uint24 public immutable override early;

    uint256 internal immutable earlySeed;

    constructor() payable {
        genesis = (block.number / INTERVAL) * INTERVAL;

        earlySeed = uint256(keccak256(abi.encodePacked(block.number, msg.sender)));

        early = uint24(msg.value / STARTING_PRICE);

        dotnuggv1 = new DotnuggV1();

        xnuggftv1 = IxNuggftV1(new xNuggftV1());

        stake = (msg.value << 96) + (uint256(early) << 192);

        emit Genesis(genesis, uint16(INTERVAL), uint16(OFFSET), INTERVAL_SUB, early, address(dotnuggv1), address(xnuggftv1), bytes32(stake));
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
}
