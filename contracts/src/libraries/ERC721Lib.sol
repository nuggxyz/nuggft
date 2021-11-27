pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

import '@openzeppelin/contracts/utils/Address.sol';

library ERC721Lib {
    using Address for address;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    struct Storage {
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;
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

    function isApprovedForAll(
        Storage storage s,
        address owner,
        address operator
    ) internal view returns (bool) {
        return s._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(Storage storage s, uint256 tokenId) internal view returns (address) {
        require(_exists(s, tokenId), 'ERC721: approved query for nonexistent token');

        return s._tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(Storage storage s, uint256 tokenId) internal view returns (address) {
        address owner = s._owners[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
        return owner;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(Storage storage s, address owner) internal view returns (uint256) {
        require(owner != address(0), 'ERC721: balance query for the zero address');
        return s._balances[owner];
    }

    function clearApprovals(Storage storage s, uint256 tokenId) internal {
        s._tokenApprovals[tokenId] = address(0);
        emit Approval(ownerOf(s, tokenId), address(0), tokenId);
    }

    function approvedTransferToSelf(
        Storage storage s,
        address from,
        uint256 tokenId
    ) internal {
        require(
            msg.sender == ownerOf(s, tokenId) && from == msg.sender && getApproved(s, tokenId) == address(this),
            'ERC721: transfer caller is not owner nor approved'
        );

        // Clear approvals from the previous owner
        clearApprovals(s, tokenId);

        s._balances[from] -= 1;
        s._balances[address(this)] += 1;
        s._owners[tokenId] = address(this);

        emit Transfer(from, address(this), tokenId);
    }

    function checkedTransferFromSelf(
        Storage storage s,
        address to,
        uint256 tokenId
    ) internal {
        require(
            _checkOnERC721Received(address(this), to, tokenId, ''),
            'ERC721: transfer caller is not owner nor approved'
        );

        s._balances[address(this)] -= 1;
        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function checkedMintTo(
        Storage storage s,
        address to,
        uint256 tokenId
    ) internal {
        require(
            _checkOnERC721Received(address(this), to, tokenId, ''),
            'ERC721: transfer caller is not owner nor approved'
        );

        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
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
