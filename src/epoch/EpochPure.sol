// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Epoch} from './EpochStorage.sol';

library EpochPure {
    function toStartBlock(uint256 epoch) internal pure returns (uint256 res) {
        res = ((epoch - 1) * Epoch.INTERVAL) + Epoch.GENESIS;
    }

    function toEpoch(uint256 blocknum) internal pure returns (uint256 res) {
        res = ((blocknum - Epoch.GENESIS) / Epoch.INTERVAL) + 1;
    }

    function toEndBlock(uint256 epoch) internal pure returns (uint256 res) {
        res = toStartBlock(epoch + 1) - 1;
    }
}
