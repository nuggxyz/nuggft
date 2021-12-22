// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {Token} from './TokenStorage.sol';
import {Global} from '../global/GlobalStorage.sol';

import {TokenView} from './TokenView.sol';

import {StakeCore} from '../stake/StakeCore.sol';
import {ProofCore} from '../proof/ProofCore.sol';

import {Trust} from '../trust/TrustStorage.sol';

// system test
library TokenCore {
    using SafeCastLib for uint256;

    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 2500;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event TrustedMint(address indexed to, uint160 tokenId);
    event UntrustedMint(address indexed by, uint160 tokenId);

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

    function untrustedMint(uint160 tokenId) internal {
        require(tokenId < UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS && tokenId > TRUSTED_MINT_TOKENS, 'T:1');

        require(!TokenView.exists(tokenId), 'T:2');

        StakeCore.addStakedShareAndEth(msg.value.safe96());

        ProofCore.setProof(tokenId);

        checkedMintTo(msg.sender, tokenId);

        emit UntrustedMint(msg.sender, tokenId);
    }

    function trustedMint(
        Trust.Storage storage trust,
        address to,
        uint160 tokenId
    ) internal {
        require(trust._isTrusted, 'T:0');

        require(tokenId < TRUSTED_MINT_TOKENS && tokenId != 0, 'T:1');

        require(!TokenView.exists(tokenId), 'T:2');

        StakeCore.addStakedShareAndEth(msg.value.safe96());

        ProofCore.setProof(tokenId);

        checkedMintTo(to, tokenId);

        emit TrustedMint(to, tokenId);
    }

    function checkedMintTo(address to, uint160 tokenId) internal {
        // DEL require(SafeTransferLib.isERC721Receiver(to, tokenId), 'T:5');

        // DEL Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // token does not exist and is < 1000

    function checkedTransferFromSelf(address to, uint160 tokenId) internal {
        // DEL require(SafeTransferLib.isERC721Receiver(to, tokenId), 'T:2');

        // DEL Token.ptr().balances[address(this)] -= 1;
        // DEL Token.ptr().balances[to] += 1;
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint160 tokenId) internal {
        // ERC721: transfer caller is not owner nor approved
        require(msg.sender == TokenView.ownerOf(tokenId) && TokenView.getApproved(tokenId) == address(this), 'T:4');

        // DEL Token.ptr().balances[msg.sender] -= 1;
        // DEL Token.ptr().balances[address(this)] += 1;
        Token.ptr().owners[tokenId] = address(this);

        // Clear approvals from the previous owner
        delete Token.ptr().approvals[tokenId];

        emit Approval(address(this), address(0), tokenId);

        emit Transfer(msg.sender, address(this), tokenId);
    }

    function checkedPreMintFromSwap(uint160 tokenId) internal {
        StakeCore.addStakedShareAndEth(msg.value.safe96());

        ProofCore.setProofFromEpoch(tokenId);

        emit Transfer(address(0), address(this), tokenId);
    }

    function onBurn(uint160 tokenId) internal {
        require(TokenView.getApproved(tokenId) == address(this), 'T:6');

        require(TokenView.ownerOf(tokenId) == msg.sender, 'T:7');

        delete Token.ptr().owners[tokenId];
        delete Token.ptr().approvals[tokenId];

        delete Global.ptr().swap.map[tokenId];
        delete Global.ptr().loan.map[tokenId];
        delete Global.ptr().proof.map[tokenId];
        delete Global.ptr().file.resolvers[tokenId];

        emit Approval(msg.sender, address(0), tokenId);

        // DEL Token.ptr().balances[msg.sender] -= 1;

        emit Transfer(msg.sender, address(0), tokenId);
    }
}
