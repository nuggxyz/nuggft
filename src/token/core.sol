// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Token} from './storage.sol';

import {TokenView} from './view.sol';

import {StakeCore} from '../stake/core.sol';

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

library TokenCore {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                APPROVAL
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedSetApprovalForAll(address operator, bool approved) internal {
        require(msg.sender != operator && operator == address(this), 'TL:0');

        Token.ptr().operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function checkedApprove(address account, uint256 tokenId) internal {
        address owner = TokenView.ownerOf(tokenId);

        // ERC721: approval to current owner
        require(account != owner, 'TL:0');

        // ERC721: approve caller is not owner nor approved for all
        require(msg.sender == owner || TokenView.isApprovedForAll(owner, msg.sender), 'TL:0');

        Token.ptr().approvals[tokenId] = account;

        emit Approval(owner, account, tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRANSFER
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedTransferFromSelf(address to, uint256 tokenId) internal {
        // TODO: we should check this before we allow someeone to offer
        require(SafeTransferLib.isERC721Receiver(to, tokenId), 'TL:0');

        Token.ptr().balances[address(this)] -= 1;
        Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint256 tokenId) internal {
        // ERC721: transfer caller is not owner nor approved
        require(msg.sender == TokenView.ownerOf(tokenId) && TokenView.getApproved(tokenId) == address(this), 'TL:4');

        Token.ptr().balances[msg.sender] -= 1;
        Token.ptr().balances[address(this)] += 1;
        Token.ptr().owners[tokenId] = address(this);

        // Clear approvals from the previous owner
        delete Token.ptr().approvals[tokenId];

        // @todo do I need this??
        // emit Approval(address(this), address(0), tokenId);

        emit Transfer(msg.sender, address(this), tokenId);
    }

    function checkedMintTo(address to, uint256 tokenId) internal {
        // ERC721: transfer caller is not owner nor approved
        require(SafeTransferLib.isERC721Receiver(to, tokenId), 'TL:4');

        Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function onBurn(uint256 tokenId) internal {
        require(TokenView.getApproved(tokenId) == address(this), 'TL:BFS:0');

        require(TokenView.ownerOf(tokenId) == msg.sender, 'TL:BFS:1');

        // @todo do I need this??
        // emit Approval(owner, address(0), tokenId);

        Token.ptr().balances[msg.sender] -= 1;

        emit Transfer(msg.sender, address(0), tokenId);

        StakeCore.subStakedSharePayingSender();
    }
}
