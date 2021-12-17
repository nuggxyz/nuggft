// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochView} from '../../../epoch/EpochView.sol';

contract EpochViewTest__calculateSeed is t {
    function test_a() public {
        hevm.warp(100);
        (uint256 seed, uint256 epoch) = EpochView.calculateSeed();

        emit log_named_uint('seed', seed);
        assertEq(seed, 0);
    }
}
