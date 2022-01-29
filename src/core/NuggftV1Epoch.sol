// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {INuggftV1Epoch} from '../interfaces/nuggftv1/INuggftV1Epoch.sol';

import {NuggftV1Constants} from './NuggftV1Constants.sol';

abstract contract NuggftV1Epoch is INuggftV1Epoch, NuggftV1Constants {
    uint256 public immutable override genesis;

    uint8 constant SWAP_FLAG = 0x3;
    uint8 constant LOAN_FLAG = 0x2;
    uint8 constant OWN_FLAG = 0x01;

    constructor() {
        genesis = (block.number / INTERVAL) * INTERVAL;
        emit Genesis(genesis, INTERVAL, OFFSET);
    }

    /// @inheritdoc INuggftV1Epoch
    function epoch() public view override returns (uint24 res) {
        require(block.number >= genesis, hex'03');
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

    /// @notice calculates a random-enough seed that will stay the
    function calculateSeed(uint24 _epoch) internal view returns (uint256 res) {
        uint256 startblock = toStartBlock(_epoch, genesis);
        unchecked {
            bytes32 bhash = getBlockHash(startblock - INTERVAL_SUB);
            require(bhash != 0, hex'0E');
            res = uint256(keccak256(abi.encodePacked(bhash, _epoch, address(this))));
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
