// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Epoch} from './storage.sol';

library EpochView {
    function activeEpoch() internal view returns (uint256 res) {
        res = toEpoch(block.number);
    }

    /**
     * @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
     * Note: by using the block hash no one knows what a nugg will look like before it's epoch.
     * We considered making this harder to manipulate, but we decided that if someone were able to
     * pull it off and make their own custom nugg, that would be really fucking cool.
     */
    function calculateSeed() internal view returns (uint256 res, uint256 epoch) {
        epoch = toEpoch(block.number);
        uint256 startblock = toStartBlock(epoch);
        bytes32 bhash = blockhash(startblock - 1);
        require(bhash != 0, 'EPC:SBL');
        res = uint256(keccak256(abi.encodePacked(bhash, epoch, address(this))));
    }

    function toStartBlock(uint256 epoch) internal pure returns (uint256 res) {
        res = (epoch * Epoch.INTERVAL) + Epoch.GENESIS;
    }

    function toEpoch(uint256 blocknum) internal pure returns (uint256 res) {
        res = (blocknum - Epoch.GENESIS) / Epoch.INTERVAL;
    }

    function toEndBlock(uint256 epoch) internal pure returns (uint256 res) {
        res = toStartBlock(epoch + 1) - 1;
    }
}
