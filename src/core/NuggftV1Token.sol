// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

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
    function ownerOf(uint256 tokenId) external view override returns (address res) {
        uint256 cache = agency[tokenId];
        require(cache != 0, hex'40');
        if (cache >> 254 == 0x03 && (cache << 2) >> 232 != 0) {
            return address(this);
        }
        return cache.account();
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

    function mint__dirty(address to, uint160 tokenId) internal {
        assembly {
            let mptr := mload(0x40)

            mstore(mptr, tokenId)
            mstore(add(mptr, 0x20), agency.slot)

            let agency__sptr := keccak256(mptr, 0x40)

            // update agency to reflect the new leader
            // =======================
            // agency[tokenId] = {
            //     flag  = OWN(0x01)
            //     epoch = 0
            //     eth   = 0
            //     addr  = to
            // }
            // =======================
            let agency__cache := or(shl(254, 0x01), to)

            sstore(agency__sptr, agency__cache)

            log4(0x00, 0x00, TRANSFER, 0, to, tokenId)
        }
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function exists(uint160 tokenId) internal view virtual returns (bool) {
        return agency[tokenId] != 0;
    }

    function isOwner(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return cache.account() == sender && uint8(cache.flag()) == 0x01;
    }

    function isAgent(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];

        if (uint160(cache) == uint160(sender)) {
            if (
                uint8(cache.flag()) == 0x01 || //
                uint8(cache.flag()) == 0x02 ||
                (uint8(cache.flag()) == 0x03 && ((cache >> 230) & 0xffffff) == 0)
            ) return true;
        }
    }
}
