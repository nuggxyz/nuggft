// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC165, IERC721Metadata} from '../interfaces/IERC721.sol';
import {ITokenExternal} from '../interfaces/nuggft/ITokenExternal.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {Token} from './TokenStorage.sol';
import {TokenView} from './TokenView.sol';
import {TokenCore} from './TokenCore.sol';

///
/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard
///
abstract contract TokenExternal is ITokenExternal {
    using SafeCastLib for uint256;

    function mint(uint160 tokenId) public payable override {
        TokenCore.untrustedMint(tokenId);
    }

    function approve(address to, uint256 tokenId) public override {
        TokenCore.checkedApprove(to, tokenId.safe160());
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

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return TokenView.ownerOf(tokenId.safe160());
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        return TokenView.getApproved(tokenId.safe160());
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return TokenView.isApprovedForAll(owner, operator);
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
