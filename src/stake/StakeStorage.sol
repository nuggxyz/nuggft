// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from '../global/GlobalStorage.sol';

library Stake {
    struct Storage {
        address trustedMigrator;
        uint256 data;
    }

    function sstore(uint256 input) internal {
        Global.ptr().stake.data = input;
    }

    function spointer() internal view returns (Storage storage s) {
        return Global.ptr().stake;
    }

    function sload() internal view returns (uint256 res) {
        return Global.ptr().stake.data;
    }
}
