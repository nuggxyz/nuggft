// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Epoch} from '../interfaces/nuggftv1/INuggftV1Epoch.sol';

abstract contract NuggftV1Epoch is INuggftV1Epoch {
    uint256 public immutable genesis;

    uint32 constant INTERVAL = 69;
    uint32 constant OFFSET = 3000;

    constructor() {
        genesis = block.number;
        emit Genesis(block.number, INTERVAL, OFFSET);
    }

    /// @inheritdoc INuggftV1Epoch
    function epoch() public view override returns (uint32 res) {
        res = toEpoch(block.number);
    }

    function toStartBlock(uint32 _epoch) internal view returns (uint256 res) {
        res = ((_epoch - OFFSET) * INTERVAL) + genesis;
    }

    function toEpoch(uint256 blocknum) internal view returns (uint32 res) {
        res = (uint32(blocknum - genesis) / INTERVAL) + OFFSET;
    }

    function toEndBlock(uint32 _epoch) internal view returns (uint256 res) {
        res = toStartBlock(_epoch + 1) - 1;
    }

    function activeEpoch() internal view returns (uint32 res) {
        res = toEpoch(block.number);
    }

    /// @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
    /// Note: by using the block hash no one knows what a nugg will look like before it's epoch.
    /// We considered making this harder to manipulate, but we decided that if someone were able to
    /// pull it off and make their own custom nugg, that would be really fucking cool.
    function calculateSeed() internal view returns (uint256 res, uint32 _epoch) {
        _epoch = epoch();
        uint256 startblock = toStartBlock(_epoch);
        bytes32 bhash = blockhash(startblock - 1);
        require(bhash != 0, 'E:0');
        res = uint256(keccak256(abi.encodePacked(bhash, _epoch, address(this))));
    }
}
