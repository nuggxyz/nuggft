// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import './IDotNuggImplementer.sol';
import './INuggMintable.sol';

/**
 * @title ILaunchable
 * @dev interface for Launchable.sol
 */
interface INuggFT is IDotNuggImplementer, INuggMintable, IERC721 {

}
