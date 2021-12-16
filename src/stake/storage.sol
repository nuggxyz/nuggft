// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/storage.sol';

library Stake {
    struct Storage {
        uint256 data;
    }

    function ptr() internal pure returns (Storage storage s) {
        return Global.ptr().stake;
    }
}
