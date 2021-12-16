// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC721Receiver, IERC721, IERC165, IERC721Metadata} from '../interfaces/IERC721.sol';

import {IToken} from '../interfaces/INuggFT.sol';

import {Token} from './storage.sol';

import {TokenView} from './view.sol';

import './logic.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract TokenExternal is TokenExternal {
    bytes32 immutable _name;

    bytes32 immutable _symbol;

    constructor(bytes32 name_, bytes32 symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(uint256 tokenId) external {
        Global.ptr().burnForStake(tokenId);
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        TokenLogic.checkedApprove(to, tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public override {
        TokenLogic.checkedSetApprovalForAll(operator, approved);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return string(abi.encodePacked(_name));
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return string(abi.encodePacked(_symbol));
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory);

    /**
     * @dev See {IERC721-_}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        return TokenView.balanceOf(owner);
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return TokenView.ownerOf(tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        return TokenView.getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return TokenView.isApprovedForAll(owner, operator);
    }

    /*///////////////////////////////////////////////////////////////
                                DISABLED
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address,
        address,
        uint256
    ) public override {
        revert('wut');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address,
        address,
        uint256
    ) public override {
        revert('wut');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public override {
        revert('wut');
    }
}
