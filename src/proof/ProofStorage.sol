// SPDX-License-Identifier: MIT

import {Global} from '../global/GlobalStorage.sol';

pragma solidity 0.8.9;

library Proof {
    struct Storage {
        mapping(uint256 => uint256) map;
        mapping(uint256 => uint256) protcolItems;
    }

    function ptr() internal view returns (Storage storage s) {
        s = Global.ptr().proof;
    }

    function get(uint160 tokenId) internal view returns (uint256) {
        return ptr().map[tokenId];
    }

    function set(uint160 tokenId, uint256 data) internal {
        ptr().map[tokenId] = data;
    }
}
