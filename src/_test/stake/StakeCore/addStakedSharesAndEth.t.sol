// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

contract StakeCoreTest__addStakedSharesAndEth is t {
    function test__StakeCore__addStakedShareAndEth__a() public {
        StakeCore.addStakedShareAndEth(0);
    }
}
