// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721} from '../interfaces/IERC721.sol';

import {INuggftV1Token} from '../interfaces/nuggftv1/INuggftV1Token.sol';

import {CastLib} from '../libraries/CastLib.sol';
import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

import {NuggftV1Epoch} from './NuggftV1Epoch.sol';

///
/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard
///
abstract contract NuggftV1Token is INuggftV1Token, NuggftV1Epoch {
    using NuggftV1AgentType for uint256;

    using CastLib for uint256;

    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 10000;

    mapping(uint256 => uint256) agency;

    // mapping(address => uint256) balances;
    mapping(uint256 => address) approvals;
    mapping(address => mapping(address => bool)) operatorApprovals;

    /// @inheritdoc IERC721
    function approve(address, uint256) external payable override {
        revert(hex'69');
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address, bool) external pure override {
        revert(hex'69');
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view override returns (address) {
        uint256 cache = agency[tokenId];
        require(cache != 0, hex'40');
        return cache.account(); //_ownerOf(tokenId.to160());
    }

    /// @inheritdoc IERC721
    function getApproved(uint256) external pure override returns (address) {
        return address(0); //_getApproved(tokenId.to160());
    }

    /// @inheritdoc IERC721
    function isApprovedForAll(address, address) external pure override returns (bool) {
        return false; //_isOperatorFor(operator, owner);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                DISABLED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function balanceOf(address) external pure override returns (uint256) {
        return 0;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) external payable override {
        revert(hex'69');
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) external payable override {
        revert(hex'69');
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) external payable override {
        revert(hex'69');
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function _mintTo(address to, uint160 tokenId) internal {
        agency[tokenId] = NuggftV1AgentType.create(0, to, 0, NuggftV1AgentType.Flag.OWN);

        emit Transfer(address(0), to, tokenId);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function exists(uint160 tokenId) internal view virtual returns (bool) {
        return agency[tokenId] != 0;
    }

    function isOwner(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return cache.account() == sender && cache.flag() == NuggftV1AgentType.Flag.OWN;
    }

    function isAgent(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return cache.account() == sender && (cache.flag() == NuggftV1AgentType.Flag.OWN || cache.flag() == NuggftV1AgentType.Flag.LOAN);
    }
}
