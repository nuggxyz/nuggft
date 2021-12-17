// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

library Stake {
    struct Storage {
        uint256 data;
    }

    function ptr() internal view returns (Storage storage s) {
        return Global.ptr().stake;
    }
}
