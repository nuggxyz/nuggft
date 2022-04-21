// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IDotnuggV1Safe} from "../interfaces/dotnugg/IDotnuggV1Safe.sol";
import {NuggftV1Items} from "../NuggftV1Items.sol";
import {NuggftV1Constants} from "./NuggftV1Constants.sol";
import {INuggftV1Globals} from "../interfaces/nuggftv1/INuggftV1Globals.sol";

abstract contract NuggftV1Globals is NuggftV1Constants, INuggftV1Globals {
    mapping(uint24 => uint256) public override proof;
    mapping(uint24 => uint256) public override agency;

    mapping(address => uint256) public balance;
    mapping(uint16 => uint256) public lastItemSwap;

    mapping(uint24 => mapping(address => uint256)) internal _offers;
    mapping(uint40 => mapping(uint24 => uint256)) internal _itemOffers;
    mapping(uint40 => uint256) internal _itemAgency;

    uint256 public override stake;
    address public override migrator;

    uint256 public immutable override genesis;
    IDotnuggV1Safe public immutable override dotnuggv1;
    NuggftV1Items public immutable inuggftv1;
    uint24 public immutable override early;

    uint256 internal immutable earlySeed;

    constructor(address dotnugg) payable {
        genesis = (block.number / INTERVAL) * INTERVAL;

        earlySeed = uint256(keccak256(abi.encodePacked(block.number, msg.sender)));

        early = uint24(msg.value / STARTING_PRICE);

        dotnuggv1 = IDotnuggV1Safe(dotnugg);
        inuggftv1 = new NuggftV1Items();

        stake = (msg.value << 96) + (uint256(early) << 192);

        emit Genesis(genesis, uint16(INTERVAL), uint16(OFFSET), INTERVAL_SUB, early, address(dotnugg), address(inuggftv1), bytes32(stake));
    }
}

// address res;

// assembly {
//     mstore(0x02, caller())
//     mstore8(0x00, 0xD6)
//     mstore8(0x01, 0x94)
//     mstore8(0x16, 0x01)

//     res := shr(96, shl(96, keccak256(0x00, 0x17)))
// }

// firse index of sender
