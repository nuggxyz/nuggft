// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

// OK
library Token {
    struct Storage {
        mapping(uint256 => address) owners;
        mapping(address => uint256) balances;
        mapping(uint256 => address) approvals;
        mapping(address => mapping(address => bool)) operatorApprovals;
    }

    function ptr() internal view returns (Storage storage s) {
        return Global.ptr().token;
    }
}
