// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './IAuctionable.sol';
import '../../interfaces/ISeedable.sol';
import '../../interfaces/IEpochable.sol';

/**
 * @title ISeedable
 * @dev interface for Seedable.sol
 */
interface INuggMinter is IAuctionable, ISeedable, IEpochable {
    // function pendingReward() external returns (uint256);
    // function movePendingReward() external;

    function currentAuction() external view returns (Auction memory res);
}
