// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {IERC721} from '../interfaces/IERC721.sol';

import {INuggftV1Token} from '../interfaces/nuggftv1/INuggftV1Token.sol';

import {NuggftV1Epoch} from './NuggftV1Epoch.sol';

///
/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard
///
abstract contract NuggftV1Token is INuggftV1Token, NuggftV1Epoch {
    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 10000;

    mapping(uint256 => uint256) public agency;

    // mapping(address => uint256) balances;
    mapping(uint256 => address) approvals;
    mapping(address => mapping(address => bool)) operatorApprovals;

    /// @inheritdoc IERC721
    function approve(address, uint256) external payable override {
        _panic(Error__E__0x69__Wut);
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address, bool) external pure override {
        _panic(Error__E__0x69__Wut);
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view override returns (address res) {
        uint256 cache = agency[tokenId];

        if (cache == 0) _panic(Error__N__0x78__TokenDoesNotExist);

        if (cache >> 254 == 0x03 && (cache << 2) >> 232 != 0) {
            return address(this);
        }
        return address(uint160(cache));
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
        _panic(Error__E__0x69__Wut);
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) external payable override {
        _panic(Error__E__0x69__Wut);
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) external payable override {
        _panic(Error__E__0x69__Wut);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function exists(uint160 tokenId) internal view returns (bool) {
        return agency[tokenId] != 0;
    }

    function isOwner(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return address(uint160(cache)) == sender && uint8(cache >> 254) == 0x01;
    }

    function isAgent(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];

        if (uint160(cache) == uint160(sender)) {
            if (
                uint8(cache >> 254) == 0x01 || //
                uint8(cache >> 254) == 0x02 ||
                (uint8(cache >> 254) == 0x03 && ((cache >> 230) & 0xffffff) == 0)
            ) return true;
        }
    }
}
