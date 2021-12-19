// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {Epoch} from './EpochStorage.sol';

// MANUAL

/// @title EpochPure
/// @author dub6ix.eth
/// @notice logical functions to calcualte the current epoch
/// @dev Explain to a developer any extra details
library EpochPure {
    using SafeCastLib for uint256;

    function toStartBlock(uint32 epoch) internal pure returns (uint256 res) {
        res = ((epoch - 1) * Epoch.INTERVAL) + Epoch.GENESIS;
    }

    function toEpoch(uint256 blocknum) internal pure returns (uint32 res) {
        res = (((blocknum - Epoch.GENESIS) / Epoch.INTERVAL) + 1).safe32();
    }

    function toEndBlock(uint32 epoch) internal pure returns (uint256 res) {
        res = toStartBlock(epoch + 1) - 1;
    }
}
