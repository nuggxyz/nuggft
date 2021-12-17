// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochPure} from '../../../epoch/EpochPure.sol';

contract EpochPureTest__toEpoch is t {
    function test_a() public {
        assertEq(EpochPure.toEpoch(1250000), 50000);
    }
}
