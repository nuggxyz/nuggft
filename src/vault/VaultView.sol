// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {Vault} from './VaultStorage.sol';
import {VaultPure} from './VaultPure.sol';

// TESTED
library VaultView {
    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return Vault.spointer().resolvers[tokenId] != address(0);
    }

    function resolverOf(uint160 tokenId) internal view returns (address) {
        return Vault.spointer().resolvers[tokenId];
    }

    function totalLengths() internal view returns (uint8[] memory res) {
        res = VaultPure.getLengths(Vault.spointer().lengthData);
    }
}
