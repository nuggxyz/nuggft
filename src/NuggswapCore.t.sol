// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./NuggswapCore.sol";

contract NuggswapCoreTest is DSTest {
    NuggswapCore core;

    function setUp() public {
        core = new NuggswapCore();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
