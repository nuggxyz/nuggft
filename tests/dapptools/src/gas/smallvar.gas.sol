// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

contract smallvar is DSTestExtended {
    function test_uint16_set() public {
        uint16 res = 16;
        assertEq(res, 16);
    }

    function test_uint256_set() public {
        uint256 res = 16;
        assertEq(res, 16);
    }

    function test_uint16() public {
        uint16 res = 16;
        res *= 1000;
        assertEq(res, 16000);
    }

    function test_uint256() public {
        uint256 res = 16;
        res *= 1000;
        assertEq(res, 16000);
    }

    function test_uint16_ass() public {
        uint16 res = 16;
        assembly {
            res := mul(res, 1000)
        }
        assertEq(res, 16000);
    }

    function test_uint256_ass() public {
        uint256 res = 16;
        assembly {
            res := mul(res, 1000)
        }
        assertEq(res, 16000);
    }
}
