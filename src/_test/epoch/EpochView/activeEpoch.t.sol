// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochCore} from '../../../epoch/EpochCore.sol';

contract EpochCoreTest__activeEpoch is t {
    function test__EpochCore__activeEpoch__a() public {
        hevm.roll(100);

        assertEq(EpochCore.activeEpoch(), 4);
    }
}
