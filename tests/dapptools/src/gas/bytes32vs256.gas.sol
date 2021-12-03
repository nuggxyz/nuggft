// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import '../../lib/DSTestExtended.sol';

contract bytes32vs256 is DSTestExtended {
    struct A {
        uint256 a;
        uint256 b;
        uint256 c;
        uint256 d;
        uint256 e;
        uint256 f;
        uint256 g;
        uint256 h;
    }

    // winner
    function test_uint256() public {
        uint256 res = 0xffffffffffffffffffffffffff;

        assembly {
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
            res := and(res, 0xff)
        }
        assertEq(uint256(res), uint256(res));
    }

    function test_bytes32() public {
        uint256 res = uint256(bytes32('ayyyoooo'));

        for (uint256 i = 0; i < 500; i++) {
            A memory b;
            b.a = 33;
        }
        assertEq(uint256(res), uint256(res));
    }

    // function test_calluint256() public {
    //     // uint256 res = I_AM_NOT_CONSTANT;

    //     assertEq(res, 1000);
    // }

    // function test_immutable() public {
    //     uint256 res = I_AM_IMMUTABLE;

    //     assertEq(res, 1000);
    // }
}
