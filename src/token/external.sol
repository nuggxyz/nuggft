// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC721Receiver, IERC721, IERC165, IERC721Metadata} from '../interfaces/IERC721.sol';

import {ITokenExternal} from '../interfaces/INuggFT.sol';

import {Token} from './storage.sol';

import {TokenView} from './view.sol';

import {TokenCore} from './core.sol';
import {GlobalCore} from '../global/core.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract TokenExternal is ITokenExternal {
    bytes32 immutable _name;

    bytes32 immutable _symbol;

    constructor(bytes32 name_, bytes32 symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function burn(uint256 tokenId) external {
        GlobalCore.burn(tokenId);
    }

    function approve(address to, uint256 tokenId) public override {
        TokenCore.checkedApprove(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override {
        TokenCore.checkedSetApprovalForAll(operator, approved);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function name() public view override returns (string memory) {
        return string(abi.encodePacked(_name));
    }

    function symbol() public view override returns (string memory) {
        return string(abi.encodePacked(_symbol));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory);

    function balanceOf(address owner) public view override returns (uint256) {
        return TokenView.balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return TokenView.ownerOf(tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        return TokenView.getApproved(tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return TokenView.isApprovedForAll(owner, operator);
    }

    /*///////////////////////////////////////////////////////////////
                                DISABLED
    //////////////////////////////////////////////////////////////*/

    function transferFrom(
        address,
        address,
        uint256
    ) public pure override {
        revert('wut');
    }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) public pure override {
        revert('wut');
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override {
        revert('wut');
    }
}
