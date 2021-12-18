// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

library Loan {
    struct Mapping {
        mapping(uint256 => uint256) map;
    }

    function sstore(uint160 tokenId, uint256 data) internal {
        Global.ptr().loan.map[tokenId] = data;
    }

    function spurge(uint160 tokenId) internal {
        delete Global.ptr().loan.map[tokenId];
    }

    function sload(uint160 tokenId) internal view returns (uint256) {
        return Global.ptr().loan.map[tokenId];
    }
}
