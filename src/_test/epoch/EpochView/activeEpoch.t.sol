// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochView} from '../../../epoch/EpochView.sol';

contract EpochViewTest__activeEpoch is t {
    function test__EpochView__activeEpoch__a() public {
        hevm.roll(100);

        assertEq(EpochView.activeEpoch(), 4);
    }
}
