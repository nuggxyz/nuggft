// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

library Vault {
    struct Storage {
        uint256 lengthData;
        uint256[] ptrs;
        // Mapping from token ID to owner address
        mapping(uint256 => address) resolvers;
    }

    function ptr() internal view returns (Storage storage s) {
        return Global.ptr().vault;
    }
}
