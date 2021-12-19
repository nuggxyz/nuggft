// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Vault} from './VaultStorage.sol';

// TESTED
library VaultView {
    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return Vault.spointer().resolvers[tokenId] != address(0);
    }

    function resolverOf(uint160 tokenId) internal view returns (address) {
        return Vault.spointer().resolvers[tokenId];
    }
}
