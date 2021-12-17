// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {StakeView} from '../../../stake/StakeView.sol';

contract StakeViewTest__getActiveEthPerShare is t {
    function test__StakeView__getActiveEthPerShare__a() public {
        assertEq(StakeView.getActiveEthPerShare(), 0);
    }
}
