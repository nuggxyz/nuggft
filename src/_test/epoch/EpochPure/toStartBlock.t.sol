// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochPure} from '../../../epoch/EpochPure.sol';

contract EpochPureTest__toStartBlock is t {
    function test_a() public {
        assertEq(EpochPure.toStartBlock(19), 451);
    }

    function test_b() public {
        assertEq(EpochPure.toStartBlock(112), 2776);
    }

    function test_c() public {
        assertEq(EpochPure.toStartBlock(22), 526);
    }

    function testFail_d() public pure {
        EpochPure.toStartBlock(0);
    }
}
