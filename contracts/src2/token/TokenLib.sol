// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Address.sol';

import './Token.sol';

library TokenLib {
    using Address for address;
    using Token for Token.Storage;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function checkedTransferFromSelf(
        Token.Storage storage s,
        address to,
        uint256 tokenId
    ) internal {
        require(Token._checkOnERC721Received(address(this), to, tokenId, ''), 'ERC721: transfer caller is not owner nor approved');

        s._balances[address(this)] -= 1;
        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(
        Token.Storage storage s,
        address from,
        uint256 tokenId
    ) internal {
        require(
            msg.sender == s._ownerOf(tokenId) && from == msg.sender && s._getApproved(tokenId) == address(this),
            'ERC721: transfer caller is not owner nor approved'
        );

        s._balances[from] -= 1;
        s._balances[address(this)] += 1;
        s._owners[tokenId] = address(this);

        // Clear approvals from the previous owner
        s._tokenApprovals[tokenId] = address(0);
        emit Approval(address(this), address(0), tokenId);

        emit Transfer(from, address(this), tokenId);
    }

    function checkedMintTo(
        Token.Storage storage s,
        address to,
        uint256 tokenId
    ) internal {
        require(Token._checkOnERC721Received(address(this), to, tokenId, ''), 'ERC721: transfer caller is not owner nor approved');

        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
}
