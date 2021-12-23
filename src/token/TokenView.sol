// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Token} from './TokenStorage.sol';
import {Proof} from '../proof/ProofStorage.sol';

library TokenView {
    function exists(uint160 tokenId) internal view returns (bool) {
        return Proof.sload(tokenId) != 0;
    }

    function isOperatorFor(address operator, address owner) internal view returns (bool) {
        return owner == operator || Token.ptr().operatorApprovals[owner][operator];
    }

    function isOperatorForOwner(address operator, uint160 tokenId) internal view returns (bool) {
        return isOperatorFor(operator, ownerOf(tokenId));
    }

    function getApproved(uint160 tokenId) internal view returns (address) {
        require(exists(tokenId), 'T:9:1');
        return Token.ptr().approvals[tokenId];
    }

    function ownerOf(uint160 tokenId) internal view returns (address owner) {
        require(exists(tokenId), 'T:9:2');
        owner = Token.ptr().owners[tokenId];
        if (owner == address(0)) return address(this);
    }

    function isApprovedOrOwner(address spender, uint160 tokenId) internal view returns (bool) {
        address owner = TokenView.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isOperatorFor(owner, spender));
    }
}
