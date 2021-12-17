// SPDX-License-Identifier: MIT

import {Global} from '../global/GlobalStorage.sol';

pragma solidity 0.8.9;

library Loan {
    struct Mapping {
        mapping(uint256 => uint256) map;
    }

    function ptr() internal view returns (Mapping storage m) {
        return Global.ptr().loan;
    }

    function handleBurn(uint256 tokenId) internal {
        delete ptr().map[tokenId];
    }

    function sload(uint256 tokenId) internal view returns (uint256) {
        return ptr().map[tokenId];
    }

    function sstore(uint256 tokenId, uint256 data) internal {
        ptr().map[tokenId] = data;
    }

    function spurge(uint256 tokenId) internal {
        delete ptr().map[tokenId];
    }
}
