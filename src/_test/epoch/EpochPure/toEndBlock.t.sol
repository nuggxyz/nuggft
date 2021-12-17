// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochPure} from '../../../epoch/EpochPure.sol';

contract EpochPureTest__toEndBlock is t {
    function test_a() public {
        assertEq(EpochPure.toEndBlock(100), 2500);
    }
}
