// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Token} from './TokenStorage.sol';

library TokenView {
    function exists(uint160 tokenId) internal view returns (bool) {
        return Token.ptr().owners[tokenId] != address(0);
    }

    function isApprovedForAll(address owner, address operator) internal view returns (bool) {
        return Token.ptr().operatorApprovals[owner][operator];
    }

    function getApproved(uint160 tokenId) internal view returns (address) {
        require(exists(tokenId), 'T:9');
        return Token.ptr().approvals[tokenId];
    }

    function ownerOf(uint160 tokenId) internal view returns (address owner) {
        owner = Token.ptr().owners[tokenId];
        require(owner != address(0), 'T:A');
    }

    function balanceOf(address owner) internal view returns (uint256) {
        require(owner != address(0), 'T:B');
        return Token.ptr().balances[owner];
    }

    function isApprovedOrOwner(address spender, uint160 tokenId) internal view returns (bool) {
        address owner = TokenView.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
