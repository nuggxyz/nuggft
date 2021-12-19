// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {Token} from './TokenStorage.sol';
import {Global} from '../global/GlobalStorage.sol';

import {TokenView} from './TokenView.sol';

import {StakeCore} from '../stake/StakeCore.sol';

// system test
library TokenCore {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                APPROVAL
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedSetApprovalForAll(address operator, bool approved) internal {
        require(msg.sender != operator && operator == address(this), 'T:0');

        Token.ptr().operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function checkedApprove(address account, uint160 tokenId) internal {
        address owner = TokenView.ownerOf(tokenId);

        // ERC721: approval to current owner
        require(account != owner, 'T:3');

        // ERC721: approve caller is not owner nor approved for all
        require(msg.sender == owner || TokenView.isApprovedForAll(owner, msg.sender), 'T:1');

        Token.ptr().approvals[tokenId] = account;

        emit Approval(owner, account, tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRANSFER
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedTransferFromSelf(address to, uint160 tokenId) internal {
        require(SafeTransferLib.isERC721Receiver(to, tokenId), 'T:2');

        Token.ptr().balances[address(this)] -= 1;
        Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint160 tokenId) internal {
        // ERC721: transfer caller is not owner nor approved
        require(msg.sender == TokenView.ownerOf(tokenId) && TokenView.getApproved(tokenId) == address(this), 'T:4');

        Token.ptr().balances[msg.sender] -= 1;
        Token.ptr().balances[address(this)] += 1;
        Token.ptr().owners[tokenId] = address(this);

        // Clear approvals from the previous owner
        delete Token.ptr().approvals[tokenId];

        emit Approval(address(this), address(0), tokenId);

        emit Transfer(msg.sender, address(this), tokenId);
    }

    function checkedMintTo(address to, uint160 tokenId) internal {
        // ERC721: transfer caller is not owner nor approved
        require(SafeTransferLib.isERC721Receiver(to, tokenId), 'T:5');

        Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function onBurn(uint160 tokenId) internal {
        require(TokenView.getApproved(tokenId) == address(this), 'T:6');

        require(TokenView.ownerOf(tokenId) == msg.sender, 'T:7');

        delete Token.ptr().owners[tokenId];
        delete Token.ptr().approvals[tokenId];

        delete Global.ptr().swap.map[tokenId];
        delete Global.ptr().loan.map[tokenId];
        delete Global.ptr().proof.map[tokenId];
        delete Global.ptr().vault.resolvers[tokenId];

        emit Approval(msg.sender, address(0), tokenId);

        Token.ptr().balances[msg.sender] -= 1;

        emit Transfer(msg.sender, address(0), tokenId);
    }
}
