// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

contract StakeCoreTest__activeStakedShares is t {
    function test__StakeCore__activeStakedShares__a() public {
        assertEq(StakeCore.activeStakedShares(), 0);
    }
}
