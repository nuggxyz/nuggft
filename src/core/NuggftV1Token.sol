// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721} from '../interfaces/IERC721.sol';

import {INuggftV1Token} from '../interfaces/nuggftv1/INuggftV1Token.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

import {NuggftV1Epoch} from './NuggftV1Epoch.sol';

///
/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard
///
abstract contract NuggftV1Token is INuggftV1Token, NuggftV1Epoch {
    using NuggftV1AgentType for uint256;

    using SafeCastLib for uint256;

    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 10000;

    mapping(uint256 => uint256) agency;

    // mapping(address => uint256) balances;
    mapping(uint256 => address) approvals;
    mapping(address => mapping(address => bool)) operatorApprovals;

    /// @inheritdoc IERC721
    function approve(address to, uint256 tokenId) public payable override {
        require(_ownerOf(tokenId.safe160()) == msg.sender, 'Z:1');

        approvals[tokenId] = to;

        emit Approval(msg.sender, to, tokenId);
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address operator, bool approved) public override {
        // require(msg.sender != operator && operator == address(this), 'G:0');

        operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view override returns (address) {
        return _ownerOf(tokenId.safe160());
    }

    /// @inheritdoc IERC721
    function getApproved(uint256 tokenId) external view override returns (address) {
        return _getApproved(tokenId.safe160());
    }

    /// @inheritdoc IERC721
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _isOperatorFor(operator, owner);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                DISABLED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function balanceOf(address) public pure override returns (uint256) {
        return 0;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public payable override {
        revert();
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public payable override {
        revert();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public payable override {
        revert();
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _mintTo(address to, uint160 tokenId) internal {
        agency[tokenId] = NuggftV1AgentType.newAgentType(0, to, 0, false);

        emit Transfer(address(0), to, tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function exists(uint160 tokenId) internal view virtual returns (bool);

    function _isOperatorFor(address operator, address owner) internal view returns (bool) {
        return owner == operator || operatorApprovals[owner][operator];
    }

    function _isOperatorForOwner(address operator, uint160 tokenId) internal view returns (bool) {
        return _isOperatorFor(operator, _ownerOf(tokenId));
    }

    function ensureOperatorForOwner(address operator, uint160 tokenId) internal view returns (address owner) {
        owner = _ownerOf(tokenId);
        require(_isOperatorFor(operator, owner), 'P:B');
    }

    function _getApproved(uint160 tokenId) internal view returns (address) {
        require(exists(tokenId), 'T:9:1');
        return approvals[tokenId];
    }

    function _ownerOf(uint160 tokenId) internal view returns (address owner) {
        require(exists(tokenId), 'T:9:2');
        owner = agency[tokenId].account();
        if (owner == address(0)) return address(this);
    }

    function isOwner(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return cache.account() == sender && !cache.flag();
    }

    function isAgent(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return cache.account() == sender;
    }

    function _isApprovedOrOwner(address spender, uint160 tokenId) internal view returns (bool) {
        address owner = _ownerOf(tokenId);
        return (spender == owner || _getApproved(tokenId) == spender || _isOperatorFor(owner, spender));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRANSFER
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedTransferFromSelf(address to, uint160 tokenId) internal {
        require(_ownerOf(tokenId) == address(this), 'N:0');

        agency[tokenId] = uint160(to);

        emitTransferEvent(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint160 tokenId) internal {
        require(_isOperatorForOwner(msg.sender, tokenId) && _getApproved(tokenId) == address(this), 'N:1');

        delete agency[tokenId];

        // Clear approvals from the previous owner
        delete approvals[tokenId];

        emitTransferEvent(msg.sender, address(this), tokenId);
    }

    function emitTransferEvent(
        address from,
        address to,
        uint160 tokenId
    ) internal {
        emit Transfer(from, to, tokenId);
    }
}
