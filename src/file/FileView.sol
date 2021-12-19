// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';

import {File} from './FileStorage.sol';
import {FilePure} from './FilePure.sol';

// TESTED
library FileView {
    function hasResolver(uint160 tokenId) internal view returns (bool) {
        return File.spointer().resolvers[tokenId] != address(0);
    }

    function resolverOf(uint160 tokenId) internal view returns (address) {
        return File.spointer().resolvers[tokenId];
    }

    function totalLengths() internal view returns (uint8[] memory res) {
        res = FilePure.getLengths(File.spointer().lengthData);
    }
}
