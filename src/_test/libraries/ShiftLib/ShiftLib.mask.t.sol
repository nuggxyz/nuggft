// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../utils/DSTestPlus.sol';

import '../../../libraries/ShiftLib.sol';

contract ShiftLib_mask is DSTestPlus {
    function setUp() public {}

    // function prove_z(uint8 input) public {
    //     // ShiftLib.mask(244);

    //     assertTrue(ShiftLib.mask(input) == type(uint256).max >> (256 - input));
    // }

    // function test_z() public {
    //     uint256 a = type(uint256).max;
    //     assembly {
    //         a := shr(sub(256, 128), a)
    //     }
    // }

    // function test_a() public {
    //     uint256 a = ShiftLib.mask(128);
    // }

    // function test_a2() public {
    //     assembly {
    //         let res := sub(shl(128, 1), 1)
    //     }
    // }

    // function prove_a(uint8 input) public {
    //     // ShiftLib.mask(244);

    //     assertTrue(ShiftLib.mask(input) == 2**input - 1);
    // }

    // function test_b() public {
    //     // ShiftLib.mask2(244);

    //     assembly {
    //         if not(iszero(shr(8, 0x04))) {

    //         }

    //         let a := sub(shl(355, 1), 1)
    //     }
    // }

    // function test_const0() public {
    //     uint256 a = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    //     assembly {
    //         a := not(shl(a, 128))
    //     }
    //     // assertEq(a, type(uint256).max);
    // }

    // function test_const1() public {
    //     assembly {
    //         let a := not(shl(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 128))
    //     }
    //     // assertEq(a, type(uint256).max);
    // }

    // function test_const2() public {
    //     uint256 a = type(uint256).max;
    //     assembly {
    //         a := not(shl(a, 128))
    //     }
    //     // assertEq(a, type(uint256).max);
    // }

    // function test_const3() public {
    //     // uint256 a = type(uint256).max;
    //     uint256 a;
    //     assembly {
    //         a := shl(256, 1)
    //         a := not(shl(a, 128))
    //     }
    //     // assertEq(a, type(uint256).max);
    // }

    // function test_const4() public {
    //     // uint256 a = type(uint256).max;
    //     // uint256 a;
    //     // assembly {
    //     //     a := shl(256, 1)
    //     //     a := not(shl(a, 128))
    //     // }
    //     ~(type(uint256).max << 128);
    //     // assertEq(a, type(uint256).max);
    // }

    // function test_b2(uint256 input) public {
    //     // ShiftLib.mask2(244);
    //     uint256 a;
    //     assembly {
    //         // if and(iszero(shr(8, 0x04)), 0x01) {

    //         // }

    //         a := sub(shl(input, 1), 1)
    //     }

    //     // emit log_named_uint('test', a);
    //     if (input > 255) {
    //         assertEq(a, type(uint256).max);
    //     } else {
    //         assertEq(a, 2**input - 1);
    //     }
    // }

    // function prove_d(uint256 input) public {
    //     bool a;
    //     assembly {
    //         a := iszero(shr(128, input)) // 0x42 < 256
    //     }
    //     assertTrue(a == input < 2**128);
    //     // assertTrue(((input >> 128) == 0) == (input < 2**128));
    // }

    // function test_fullsubmask_withand() public {
    //     unchecked {
    //         8 & ShiftLib.fullsubmask(8, 8);
    //     }
    // }

    // // function test_fullsubmaskand() public {
    // //     ShiftLib.fullsubmaskand(8, 8, 8);
    // // }

    // // function test_c3() public {
    // //     assembly {
    // //         let a := iszero(shr(128, 0x42)) // 0x42 < 256
    // //     }
    // //     // bool t = input >> 128 == 0;
    // // }

    // // function test_c4() public {
    // //     bool g = 0x42 < 256;
    // //     // require(pos < 256, 'SHIFT:POS:0');

    // //     // assertTrue(pos< )
    // // }
}
