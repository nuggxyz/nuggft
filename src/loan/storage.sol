// SPDX-License-Identifier: MIT

import {Global} from '../global/storage.sol';

pragma solidity 0.8.9;

library Loan {
    struct Mapping {
        mapping(uint256 => uint256) map;
    }

    function get(uint256 tokenId) internal pure returns (uint256) {
        return Global.ptr().loan.map[tokenId];
    }

    function set(uint256 tokenId, uint256 data) internal pure {
        Global.ptr().loan.map[tokenId] = data;
    }
}
