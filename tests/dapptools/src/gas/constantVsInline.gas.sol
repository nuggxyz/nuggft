// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import '../../lib/DSTestExtended.sol';

contract constantVsInline is DSTestExtended {
    uint256 constant I_AM_CONSTANT = 1000;
    uint256 I_AM_NOT_CONSTANT = 1000;
    uint256 immutable I_AM_IMMUTABLE = 1000;

    // winner
    function test_inline() public {
        uint256 res = 1000;

        assertEq(res, 1000);
    }

    function test_constant() public {
        uint256 res = I_AM_CONSTANT;

        assertEq(res, 1000);
    }

    function test_not_constant() public {
        uint256 res = I_AM_NOT_CONSTANT;

        assertEq(res, 1000);
    }

    function test_immutable() public {
        uint256 res = I_AM_IMMUTABLE;

        assertEq(res, 1000);
    }
}
