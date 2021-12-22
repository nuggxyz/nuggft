// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

contract StakeCoreTest__activeStakedEth is t {
    function test__StakeCore__activeStakedEth__a() public {
        assertEq(StakeCore.activeStakedEth(), 0);
    }
}
