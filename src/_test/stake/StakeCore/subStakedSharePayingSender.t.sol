// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

contract StakeCoreTest__subStakedSharePayingSender is t {
    function test__StakeCore__subStakedSharePayingSender__a() public {
        StakeCore.subStakedSharePayingSender(0);
    }
}
