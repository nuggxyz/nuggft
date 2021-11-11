// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol';
import '@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol';

abstract contract Registerable {
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 internal constant _TOKENS_SENDER_INTERFACE_HASH = keccak256('ERC777TokensSender');
    bytes32 internal constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256('ERC777TokensRecipient');
    bytes32 internal constant _ERC777_INTERFACE_HASH = keccak256('ERC777Token');
    bytes32 internal constant _ERC20_INTERFACE_HASH = keccak256('ERC20Token');

    uint256 private creationBlock;

    bytes4[] private _165Interfaces;

    constructor() {
        creationBlock = block.number;
    }

    function _registerAs(bytes32 b) internal {
        require(block.number == creationBlock);
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), b, address(this));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        for (uint8 i = 0; i < _165Interfaces.length; i++) {
            if (interfaceId == _165Interfaces[i]) return true;
        }
        return false;
    }
}

/** return
            super.supportsInterface(interfaceId) ||
            interfaceId == _INTERFACE_ID_ROYALTIES_CREATORCORE ||
            interfaceId == _INTERFACE_ID_ROYALTIES_EIP2981 ||
            interfaceId == _INTERFACE_ID_ROYALTIES_RARIBLE; */
