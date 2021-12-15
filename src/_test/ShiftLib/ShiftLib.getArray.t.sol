// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.4;

import '../utils/DSTestPlus.sol';

import '../../libraries/ShiftLib.sol';

contract ShiftLib_getArray is DSTestPlus {
    function setUp() public {}

    function test_a() public {
        uint256 input = 0x010101;

        uint256[] memory got = ShiftLib.getArray(input, 8, 0, 3);

        assertEq(got.length, 3);
        assertEq(got[0], 1);
        assertEq(got[1], 1);
        assertEq(got[2], 1);
    }

    // function test_b() public {
    //     uint256 input = 0x010201;

    //     uint256[] memory got = ShiftLib.getArray(input, 8, 0, 3);

    //     assertEq(got.length, 3);
    //     assertEq(got[0], 1);
    //     assertEq(got[1], 2);
    //     assertEq(got[2], 1);
    // }

    function test_b() public {
        uint256[] memory got = ShiftLib.getArray(0x01010102342120131223216312836818726, 8, 0, 32);

        assertEq(got.length, 32);

        for (uint256 i = 0; i < 32; i++) {
            assertEq(got[i], (0x01010102342120131223216312836818726 >> (i * 8)) & 0xff);
        }
    }

    function test_b(uint256 input) public {
        uint256[] memory got = ShiftLib.getArray(input, 8, 0, 32);

        assertEq(got.length, 32);

        for (uint256 i = 0; i < 32; i++) {
            assertEq(got[i], (input >> (i * 8)) & 0xff);
        }
    }
}
