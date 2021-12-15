// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./NuggftCore2.sol";

contract NuggftCore2Test is DSTest {
    NuggftCore2 core;

    function setUp() public {
        core = new NuggftCore2();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
