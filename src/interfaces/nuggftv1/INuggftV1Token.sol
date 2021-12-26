// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721} from '../IERC721.sol';

interface INuggftV1Token is IERC721 {
    function mint(uint160 tokenId) external payable;

    function trustedMint(uint160 tokenId, address to) external payable;
}
