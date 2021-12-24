// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

// MANUAL
library EpochCore {
    using SafeCastLib for uint256;

    struct Storage {
        uint32 genesis;
    }

    uint256 constant INTERVAL = 69;
    uint32 constant OFFSET = 10500;

    function setGenesis() internal {
        Storage storage s;
        assembly {
            s.slot := 0x100042069
        }

        s.genesis = uint32(block.number);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                whadduppp
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function getGenesis() internal view returns (uint32) {
        Storage storage s;

        assembly {
            s.slot := 0x100042069
        }

        return s.genesis;
    }

    function toStartBlock(uint32 epoch) internal view returns (uint256 res) {
        res = ((epoch - OFFSET) * INTERVAL) + getGenesis();
    }

    function toEpoch(uint256 blocknum) internal view returns (uint32 res) {
        res = (((blocknum - getGenesis()) / INTERVAL) + OFFSET).safe32();
    }

    function toEndBlock(uint32 epoch) internal view returns (uint256 res) {
        res = toStartBlock(epoch + 1) - 1;
    }

    function activeEpoch() internal view returns (uint32 res) {
        res = toEpoch(block.number);
    }

    /// @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
    /// Note: by using the block hash no one knows what a nugg will look like before it's epoch.
    /// We considered making this harder to manipulate, but we decided that if someone were able to
    /// pull it off and make their own custom nugg, that would be really fucking cool.
    function calculateSeed() internal view returns (uint256 res, uint32 epoch) {
        epoch = activeEpoch();
        uint256 startblock = toStartBlock(epoch);
        bytes32 bhash = blockhash(startblock - 1);
        // require(bhash != 0, 'E:0');

        if (bhash == 0) bhash = keccak256(abi.encodePacked(epoch));
        res = uint256(keccak256(abi.encodePacked(bhash, epoch, address(this))));
    }
}
