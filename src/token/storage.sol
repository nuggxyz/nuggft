// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/storage.sol';

library Token {
    struct Storage {
        // // Token symbol
        mapping(uint256 => address) owners;
        // // Token symbol
        mapping(address => uint256) balances;
        // Mapping from token ID to approved address
        mapping(uint256 => address) approvals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) operatorApprovals;
    }

    function ptr() internal pure returns (Storage storage s) {
        return Global.ptr().token;
    }
}
