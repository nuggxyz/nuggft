// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import {INuggftV1Epoch} from "../interfaces/nuggftv1/INuggftV1Epoch.sol";

import {NuggftV1Constants} from "./NuggftV1Constants.sol";

abstract contract NuggftV1Epoch is INuggftV1Epoch, NuggftV1Constants {
    uint256 public immutable override genesis;

    constructor() {
        genesis = (block.number / INTERVAL) * INTERVAL;
        emit Genesis(genesis, uint16(INTERVAL), uint16(OFFSET), INTERVAL_SUB);
    }

    /// @inheritdoc INuggftV1Epoch
    function epoch() public view override returns (uint24 res) {
        require(block.number >= genesis, "YOU MADE A BAD ROOOLLLLLLLLLLL");
        res = toEpoch(block.number, genesis);
    }

    function start(uint24 _epoch) public view returns (uint256 res) {
        res = toStartBlock(_epoch, genesis);
    }

    function end(uint24 _epoch) public view returns (uint256 res) {
        res = toEndBlock(_epoch, genesis);
    }

    function calculateSeed() internal view returns (uint256 res, uint24 _epoch) {
        _epoch = epoch();
        res = calculateSeed(_epoch);
    }

    function tryCalculateSeed(uint24 _epoch) internal view returns (uint256 res) {
        res = calculateSeed(_epoch);
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

    /// @notice calculates a random-enough seed that will stay the
    function cheat(uint256 startblock, uint24 _epoch) internal view returns (uint256 res) {
        unchecked {
            bytes32 bhash = getBlockHash(startblock - INTERVAL_SUB);

            assembly {
                mstore(0x00, bhash)
                mstore(0x20, _epoch)
                res := keccak256(0x00, 0x40)
            }
        }
    }

    function getBlockHash(uint256 blocknum) internal view virtual returns (bytes32 res) {
        return blockhash(blocknum);
    }

    function toStartBlock(uint24 _epoch, uint256 gen) public pure returns (uint256 res) {
        assembly {
            res := add(mul(sub(_epoch, OFFSET), INTERVAL), gen)
        }
    }

    function toEpoch(uint256 blocknum, uint256 gen) public pure returns (uint24 res) {
        assembly {
            res := add(div(sub(blocknum, gen), INTERVAL), OFFSET)
        }
    }

    function toEndBlock(uint24 _epoch, uint256 gen) public pure returns (uint256 res) {
        unchecked {
            res = toStartBlock(_epoch + 1, gen) - 1;
        }
    }
}
