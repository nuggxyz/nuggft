// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC165, IERC721Metadata} from '../interfaces/IERC721.sol';
import {INuggftV1Token} from '../interfaces/nuggftv1/INuggftV1Token.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {NuggftV1Epoch} from './NuggftV1Epoch.sol';

///
/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard
///
abstract contract NuggftV1Token is INuggftV1Token, NuggftV1Epoch {
    using SafeCastLib for uint256;

    uint32 constant TRUSTED_MINT_TOKENS = 500;
    uint32 constant UNTRUSTED_MINT_TOKENS = 10000;

    mapping(uint256 => address) owners;
    // mapping(address => uint256) balances;
    mapping(uint256 => address) approvals;
    mapping(address => mapping(address => bool)) operatorApprovals;

    /// @inheritdoc IERC721
    function approve(address to, uint256 tokenId) public payable override {
        address owner = _ownerOf(tokenId.safe160());

        require(_isOperatorFor(msg.sender, owner), 'G:1');

        approvals[tokenId] = to;

        emit Approval(owner, to, tokenId);
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address operator, bool approved) public override {
        // require(msg.sender != operator && operator == address(this), 'G:0');

        operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
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
        owners[tokenId] = to;

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

    function _getApproved(uint160 tokenId) internal view returns (address) {
        require(exists(tokenId), 'T:9:1');
        return approvals[tokenId];
    }

    function _ownerOf(uint160 tokenId) internal view returns (address owner) {
        require(exists(tokenId), 'T:9:2');
        owner = owners[tokenId];
        if (owner == address(0)) return address(this);
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

        owners[tokenId] = to;

        emitTransferEvent(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint160 tokenId) internal {
        require(_isOperatorForOwner(msg.sender, tokenId) && _getApproved(tokenId) == address(this), 'N:1');

        delete owners[tokenId];

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
