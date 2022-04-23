// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {NuggftV1} from "../NuggftV1.sol";
import {DotnuggV1Lib} from "../libraries/DotnuggV1Lib.sol";

contract RiggedNuggftV1 is NuggftV1 {
    constructor() payable {}

    function getBlockHash(uint256 blocknum) internal view override returns (bytes32 res) {
        if (block.number > blocknum && block.number - blocknum < 256) {
            return keccak256(abi.encodePacked(blocknum));
        }
    }

    function external__search(uint8 feature, uint256 seed) external view returns (uint8) {
        return DotnuggV1Lib.search(address(dotnuggv1), feature, seed);
    }

    function external__calculateSeed() external view returns (uint256 res, uint24 _epoch) {
        return calculateSeed();
    }

    function external__calculateSeed(uint24 epoch) external view returns (uint256 res) {
        return calculateSeed(epoch);
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
}
