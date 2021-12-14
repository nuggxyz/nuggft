// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Address.sol';

import './Token.sol';

import '../stake/StakeLib.sol';

library TokenLib {
    using Address for address payable;
    using Token for Token.Storage;
    using StakeLib for Token.Storage;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function _approve(
        Token.Storage storage nuggft,
        address to,
        uint256 tokenId
    ) internal {
        nuggft._tokenApprovals[tokenId] = to;

        emit Approval(nuggft._ownerOf(tokenId), to, tokenId);
    }

    function checkedTransferFromSelf(
        Token.Storage storage nuggft,
        address to,
        uint256 tokenId
    ) internal {
        require(Token._checkOnERC721Received(address(this), to, tokenId, ''), 'ERC721: transfer caller is not owner nor approved');

        nuggft._balances[address(this)] -= 1;
        nuggft._balances[to] += 1;
        nuggft._owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(
        Token.Storage storage nuggft,
        address from,
        uint256 tokenId
    ) internal {
        require(
            msg.sender == nuggft._ownerOf(tokenId) && from == msg.sender && nuggft._getApproved(tokenId) == address(this),
            'ERC721: transfer caller is not owner nor approved'
        );

        nuggft._balances[from] -= 1;
        nuggft._balances[address(this)] += 1;
        nuggft._owners[tokenId] = address(this);

        // Clear approvals from the previous owner
        nuggft._tokenApprovals[tokenId] = address(0);
        emit Approval(address(this), address(0), tokenId);

        emit Transfer(from, address(this), tokenId);
    }

    function checkedMintTo(
        Token.Storage storage nuggft,
        address to,
        uint256 tokenId
    ) internal {
        require(Token._checkOnERC721Received(address(this), to, tokenId, ''), 'ERC721: transfer caller is not owner nor approved');

        nuggft._balances[to] += 1;
        nuggft._owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function burnForStake(Token.Storage storage nuggft, uint256 tokenId) internal {
        require(nuggft._getApproved(tokenId) == address(this), 'TL:BFS:0');

        address owner = nuggft._ownerOf(tokenId);

        require(owner == msg.sender, 'TL:BFS:1');

        delete nuggft._tokenApprovals[tokenId];
        emit Approval(owner, address(0), tokenId);

        nuggft._balances[owner] -= 1;

        delete nuggft._owners[tokenId];
        delete nuggft._resolvers[tokenId];
        delete nuggft._proofs[tokenId];
        delete nuggft._swaps[tokenId];

        emit Transfer(owner, address(0), tokenId);

        uint256 amount = nuggft.getActiveEthPerShare();

        nuggft.subStakedEth(amount);
        nuggft.subStakedShares(1);

        payable(owner).sendValue(nuggft.getActiveEthPerShare());
    }
}
