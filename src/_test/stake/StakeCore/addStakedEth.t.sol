// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeCore} from '../../../stake/StakeCore.sol';

// import {console} from '../../utils/console.sol';

contract StakeCoreTest__addStakedEth is t {
    function test__StakeCore__addStakedEth__a() public {
        StakeCore.addStakedEth(0);

        // console.log('teeeeessstttt');
    }
}
