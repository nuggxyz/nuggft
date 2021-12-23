// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC721Metadata, IERC165} from '../IERC721.sol';

interface ITokenExternal is IERC721 {
    event TrustedMint(address indexed to, uint160 tokenId);
    event UntrustedMint(address indexed by, uint160 tokenId);

    function mint(uint160 tokenId) external payable;

    function trustedMint(uint160 tokenId, address to) external payable;
}
