// SPDX-License-Identifier: MIT

import {Vault} from './VaultStorage.sol';

library VaultView {
    function hasResolver(uint256 tokenId) internal view returns (bool) {
        return Vault.ptr().resolvers[tokenId] != address(0);
    }

    function resolverOf(uint256 tokenId) internal view returns (address) {
        return Vault.ptr().resolvers[tokenId];
    }
}
