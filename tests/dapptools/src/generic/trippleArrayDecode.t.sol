// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTest.sol';

contract trippleArrayDecode is DSTest {
    // winner
    function test_uint256() public {
        uint256[][][] memory a = new uint256[][][](1);

        bytes memory b = abi.encode(a);

        uint256[][][] memory c = abi.decode(b, (uint256[][][]));

        assertTrue(false);

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
