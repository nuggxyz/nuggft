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

    // Token.Storage internal nuggft();
    function nuggft() internal view virtual returns (Token.Storage storage);

    function genesis() public view virtual returns (uint256);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        nuggft()._name = name_;
        nuggft()._symbol = symbol_;
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
        return nuggft()._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return nuggft()._symbol;
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
        // //solhint-disable-next-line max-line-length
        // require(_isApprovedOrOwner(msg.sender, tokenId), 'ERC721: transfer caller is not owner nor approved');
        // _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
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
        // require(_isApprovedOrOwner(msg.sender, tokenId), 'ERC721: transfer caller is not owner nor approved');
        // _safeTransfer(from, to, tokenId, _data);
    }

    // /**
    //  * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
    //  * are aware of the ERC721 protocol to prevent tokens from being forever locked.
    //  *
    //  * `_data` is additional data, it has no specified format and it is sent in call to `to`.
    //  *
    //  * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
    //  * implement alternative mechanisms to perform token transfer, such as signature-based.
    //  *
    //  * Requirements:
    //  *
    //  * - `from` cannot be the zero address.
    //  * - `to` cannot be the zero address.
    //  * - `tokenId` token must exist and be owned by `from`.
    //  * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    // function _safeTransfer(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory _data
    // ) internal virtual {
    //     _transfer(from, to, tokenId);
    //     require(Token._checkOnERC721Received(from, to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    // }

    // /**
    //  * @dev Returns whether `tokenId` exists.
    //  *
    //  * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
    //  *
    //  * Tokens start existing when they are minted (`_mint`),
    //  * and stop existing when they are burned (`_burn`).
    //  */
    // function _exists(uint256 tokenId) internal view virtual returns (bool) {
    //     return nuggft()._exists(tokenId);
    // }

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

    // /**
    //  * @dev Safely mints `tokenId` and transfers it to `to`.
    //  *
    //  * Requirements:
    //  *
    //  * - `tokenId` must not exist.
    //  * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    // function _safeMint(address to, uint256 tokenId) internal virtual {
    //     _safeMint(to, tokenId, '');
    // }

    // /**
    //  * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
    //  * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
    //  */
    // function _safeMint(
    //     address to,
    //     uint256 tokenId,
    //     bytes memory _data
    // ) internal virtual {
    //     _mint(to, tokenId);
    //     require(Token._checkOnERC721Received(address(0), to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    // }

    // /**
    //  * @dev Mints `tokenId` and transfers it to `to`.
    //  *
    //  * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
    //  *
    //  * Requirements:
    //  *
    //  * - `tokenId` must not exist.
    //  * - `to` cannot be the zero address.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    // function _mint(address to, uint256 tokenId) internal virtual {
    //     require(to != address(0), 'ERC721: mint to the zero address');
    //     require(!_exists(tokenId), 'ERC721: token already minted');

    //     _beforeTokenTransfer(address(0), to, tokenId);

    //     nuggft()._balances[to] += 1;
    //     nuggft()._owners[tokenId] = to;

    //     emit Transfer(address(0), to, tokenId);
    // }

    // /**
    //  * @dev Transfers `tokenId` from `from` to `to`.
    //  *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
    //  *
    //  * Requirements:
    //  *
    //  * - `to` cannot be the zero address.
    //  * - `tokenId` token must be owned by `from`.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    // function _transfer(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) internal virtual {
    //     require(nuggft()._ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
    //     require(to != address(0), 'ERC721: transfer to the zero address');

    //     _beforeTokenTransfer(from, to, tokenId);

    //     // Clear approvals from the previous owner
    //     _approve(address(0), tokenId);

    //     nuggft()._balances[from] -= 1;
    //     nuggft()._balances[to] += 1;
    //     nuggft()._owners[tokenId] = to;

    //     emit Transfer(from, to, tokenId);
    // }

    // /**
    //  * @dev Hook that is called before any token transfer. This includes minting
    //  * and burning.
    //  *
    //  * Calling conditions:
    //  *
    //  * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
    //  * transferred to `to`.
    //  * - When `from` is zero, `tokenId` will be minted for `to`.
    //  * - When `to` is zero, ``from``'s `tokenId` will be burned.
    //  * - `from` and `to` are never both zero.
    //  *
    //  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    //  */
    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) internal virtual {}
}
