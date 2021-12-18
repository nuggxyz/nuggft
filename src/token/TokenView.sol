// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Token} from './TokenStorage.sol';

library TokenView {
    function exists(uint256 tokenId) internal view returns (bool) {
        return Token.ptr().owners[tokenId] != address(0);
    }

    function isApprovedForAll(address owner, address operator) internal view returns (bool) {
        return Token.ptr().operatorApprovals[owner][operator];
    }

    function getApproved(uint256 tokenId) internal view returns (address) {
        require(exists(tokenId), 'ERC721: approved query for nonexistent token');
        return Token.ptr().approvals[tokenId];
    }

    function ownerOf(uint256 tokenId) internal view returns (address owner) {
        owner = Token.ptr().owners[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
    }

    function balanceOf(address owner) internal view returns (uint256) {
        require(owner != address(0), 'ERC721: balance query for the zero address');
        return Token.ptr().balances[owner];
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = TokenView.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
