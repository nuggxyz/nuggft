// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Epoch} from '../interfaces/nuggftv1/INuggftV1Epoch.sol';

/// @custom:testing OK
abstract contract NuggftV1Epoch is INuggftV1Epoch {
    uint256 public immutable genesis;

    uint16 constant INTERVAL = 69;
    uint24 constant OFFSET = 3000;

    constructor() {
        genesis = block.number;
        emit Genesis(block.number, INTERVAL, OFFSET);
    }

    /// @inheritdoc INuggftV1Epoch
    function epoch() public view override returns (uint24 res) {
        res = toEpoch(block.number, genesis);
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
        bytes32 bhash = getBlockHash(startblock - 2);
        require(bhash != 0, 'E:0');
        res = uint256(keccak256(abi.encodePacked(bhash, _epoch, address(this))));
    }

    function getBlockHash(uint256 blocknum) internal view virtual returns (bytes32 res) {
        return blockhash(blocknum);
    }

    function toStartBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        assembly {
            res := add(mul(sub(_epoch, OFFSET), INTERVAL), gen)
        }
    }

    function toEpoch(uint256 blocknum, uint256 gen) internal pure returns (uint24 res) {
        assembly {
            res := add(div(sub(blocknum, gen), INTERVAL), OFFSET)
        }
    }

    function toEndBlock(uint24 _epoch, uint256 gen) internal pure returns (uint256 res) {
        unchecked {
            res = toStartBlock(_epoch + 1, gen) - 1;
        }
    }
}
