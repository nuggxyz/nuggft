// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

library Trust {
    struct Storage {
        mapping(address => bool) trusted;
    }

    function check() internal view {
        Storage storage store;

        assembly {
            store.slot := 0x20002467
        }

        require(store.trusted[msg.sender], 'T:1');
    }
}
