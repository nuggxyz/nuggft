// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

import '@openzeppelin/contracts/utils/Address.sol';

import '../swap/Swap.sol';

import '../vault/Vault.sol';

import '../../tests/Event.sol';

library Token {
    using Address for address;

    struct Storage {
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Token symbol
        uint256 _stake;
        // Token symbol
        Vault.Storage _vault;
        // Token symbol
        mapping(uint256 => uint256) _ownedItems;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;
        // Mapping from token ID to owner address
        mapping(uint256 => uint256) _loans;
        // Mapping from token ID to owner address
        mapping(uint256 => uint256) _proofs;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _resolvers;
        // Mapping from token ID to owner address
        mapping(uint256 => Swap.History) _swaps;
        // Mapping owner address to token count
        mapping(address => uint256) _balances;
        // Mapping from token ID to approved address
        mapping(uint256 => address) _tokenApprovals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(Storage storage s, uint256 tokenId) internal view returns (bool) {
        return s._owners[tokenId] != address(0);
    }

    function _hasResolver(Storage storage s, uint256 tokenId) internal view returns (bool) {
        return s._resolvers[tokenId] != address(0);
    }

    function _isApprovedForAll(
        Storage storage s,
        address owner,
        address operator
    ) internal view returns (bool) {
        return s._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function _getApproved(Storage storage s, uint256 tokenId) internal view returns (address) {
        require(_exists(s, tokenId), 'ERC721: approved query for nonexistent token');
        return s._tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function _ownerOf(Storage storage s, uint256 tokenId) internal view returns (address owner) {
        owner = s._owners[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function _proofOf(Storage storage s, uint256 tokenId) internal view returns (uint256 data) {
        data = s._proofs[tokenId];
        Event.log(data, 'data');
        require(data != 0, 'TOKEN:PO:0');
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function _resolverOf(Storage storage s, uint256 tokenId) internal view returns (address resolver) {
        resolver = s._resolvers[tokenId];
        require(resolver != address(0), 'ERC721: resolver query for nonexistent token');
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function _balanceOf(Storage storage s, address owner) internal view returns (uint256) {
        require(owner != address(0), 'ERC721: balance query for the zero address');
        return s._balances[owner];
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('ERC721: transfer to non ERC721Receiver implementer');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
