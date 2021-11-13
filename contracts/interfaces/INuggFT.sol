// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../auction/periphery/IAuctionableImplementer.sol';
import '../auction/interfaces/IAuctionable.sol';
import '../auction/interfaces/IAuctionable.sol';
import '../erc721/IERC721.sol';
import './IDotNuggImplementer.sol';

/**
 * @title ILaunchable
 * @dev interface for Launchable.sol
 */
interface INuggFT is IDotNuggImplementer, IAuctionableImplementer, IERC721 {
    function pendingTokenURI() external view returns (string memory res);
}
