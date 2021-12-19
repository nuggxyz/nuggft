// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

// TESTED
library File {
    struct Storage {
        uint256 lengthData;
        mapping(uint8 => uint168[]) ptrs;
        // Mapping from token ID to owner address
        mapping(uint256 => address) resolvers;
    }

    function spointer() internal view returns (Storage storage s) {
        return Global.ptr().file;
    }
}
