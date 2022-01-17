// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import './error.sol';
import './logger.sol';
import './store.sol';
import './DSTest.sol';
import './gas.sol';

abstract contract ForgeTest is DSTest {
    modifier prank(address user, uint256 value) {
        forge.vm.deal(user, value);
        forge.vm.startPrank(user);
        _;
        forge.vm.stopPrank();
    }
}
