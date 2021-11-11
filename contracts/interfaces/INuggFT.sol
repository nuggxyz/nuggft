// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../auction/periphery/IAuctionableImplementer.sol';
import '../auction/interfaces/IAuctionable.sol';
import '../auction/interfaces/IAuctionable.sol';
import '../erc721/IERC721.sol';

/**
 * @title ILaunchable
 * @dev interface for Launchable.sol
 */
interface INuggFT is IAuctionableImplementer, IERC721 {
    function pendingTokenURI() external view returns (string memory res);

    // function pendingTokenURI(uint256 id) external view returns (string memory res);
}
