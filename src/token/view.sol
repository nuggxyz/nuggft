// SPDX-License-Identifier: MIT

import {Token} from './storage.sol';

library TokenView {
    /**
     * @dev Returns whether `tokenId` existToken.ptr().
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`mint`),
     * and stop existing when they are burned (`burn`).
     */
    function exists(uint256 tokenId) internal view returns (bool) {
        return Token.ptr().owners[tokenId] != address(0);
    }

    function isApprovedForAll(address owner, address operator) internal view returns (bool) {
        return Token.ptr().operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) internal view returns (address) {
        require(exists(tokenId), 'ERC721: approved query for nonexistent token');
        return Token.ptr().approvals[tokenId];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) internal view returns (address owner) {
        owner = Token.ptr().owners[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
    }

    // /**
    //  * @dev See {IERC721-ownerOf}.
    //  */
    // function resolverOf(uint256 tokenId) internal view returns (address resolver) {
    //     resolver = VaultView.resolvers[tokenId];
    //     require(resolver != address(0), 'ERC721: resolver query for nonexistent token');
    // }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) internal view returns (uint256) {
        require(owner != address(0), 'ERC721: balance query for the zero address');
        return Token.ptr().balances[owner];
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = TokenView.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
