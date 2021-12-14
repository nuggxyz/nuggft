// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

import '../interfaces/INuggFT.sol';

import './Token.sol';
import './TokenLib.sol';

import '../proof/ProofLib.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract Tokenable is ITokenable, ERC165 {
    using Address for address;
    using Token for Token.Storage;
    using EpochLib for uint256;
    using TokenLib for Token.Storage;

    bytes32 immutable _name;

    bytes32 immutable _symbol;

    // Token.Storage internal nuggft();
    function nuggft() internal view virtual returns (Token.Storage storage);

    function genesis() public view virtual returns (uint256);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(bytes32 name_, bytes32 symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-_}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        return nuggft()._balanceOf(owner);
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return nuggft()._ownerOf(tokenId);
    }

    /**
     * @dev See {IERC721-_}.
     */
    function proofOf(uint256 tokenId) public view virtual override returns (uint256) {
        if (tokenId == genesis().activeEpoch()) {
            (uint256 p, , , ) = ProofLib.pendingProof(nuggft(), genesis());
            return p;
        }

        return nuggft()._proofOf(tokenId);
    }

    /**
     * @dev See {IERC721-_}.
     */
    function parsedProofOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (
            uint256 proof,
            uint256[] memory defaultIds,
            uint256[] memory extraIds,
            uint256[] memory overrides
        )
    {
        return ProofLib.parseProof(nuggft(), tokenId);
    }

    /**
     * @dev See {IERC721-_}.
     */
    function resolverOf(uint256 tokenId) public view virtual override returns (address) {
        return nuggft()._resolverOf(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return string(abi.encodePacked(_name));
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return string(abi.encodePacked(_symbol));
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}. MODIFICATION 0
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory);

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = nuggft()._ownerOf(tokenId);
        require(to != owner, 'ERC721: approval to current owner');

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), 'ERC721: approve caller is not owner nor approved for all');

        nuggft()._approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        return nuggft()._getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, 'ERC721: approve to caller');

        nuggft()._operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return nuggft()._isApprovedForAll(owner, operator);
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
    function burn(uint256 tokenId) external virtual {
        nuggft().burnForStake(tokenId);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(false, 'TOKEN:TF:0');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(false, 'TOKEN:STF:0');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(false, 'TOKEN:STF:1');
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(nuggft()._exists(tokenId), 'ERC721: operator query for nonexistent token');
        address owner = nuggft()._ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
