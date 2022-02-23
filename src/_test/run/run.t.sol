// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import '../utils/forge.sol';

contract runner {
    mapping(uint160 => uint256) tokens;

    struct Test {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    function run() external {
        Test storage s;

        // prettier-ignore
        assembly {
            s.slot := 0x4455

            // mstore(0x20, 0x4455)

            // mstore(0x00, /* 0 == position of "a" in struct */ 0)

            // sstore(keccak256(0x00, 0x40), 0xfff0)

            // mstore(0x00, /* 1 == position of "b" in struct */ 1)

            // sstore(keccak256(0x00, 0x40), 0xfff1)

            // mstore(0x00, /* 2 == position of "c" in struct */ 2)

            // sstore(keccak256(0x00, 0x40), 0xfff2)
        }

        s.a = 0xfff0;
        s.b = 0xfff1;
        s.c = 0xfff2;

        ds.inject.log(s.a);

        ds.inject.log(s.b);

        ds.inject.log(s.c);
    }
}
