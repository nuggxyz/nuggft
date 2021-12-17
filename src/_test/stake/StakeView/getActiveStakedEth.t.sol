// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeView} from '../../../stake/StakeView.sol';

contract StakeViewTest__getActiveStakedEth is t {
    function test__StakeView__getActiveStakedEth__a() public {
        assertEq(StakeView.getActiveStakedEth(), 0);
    }
}
