// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

contract StakeCoreTest__activeEthPerShare is t {
    function test__StakeCore__activeEthPerShare__a() public {
        assertEq(StakeCore.activeEthPerShare(), 0);
    }
}
