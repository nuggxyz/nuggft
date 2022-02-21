// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import './DSTest.sol';
import './logger.sol';
import './stdlib.sol';
import './gas.sol';
import './vm.sol';
import './cast.sol';
import './ds.sol';
import './lib.sol';
import './global.sol';
import './record.sol';
import './array.sol';

abstract contract ForgeTest is GasTracker, DSTest {
    modifier prank(address user, uint256 value) {
        forge.vm.deal(user, value);
        forge.vm.startPrank(user);
        _;
        forge.vm.stopPrank();
    }
}
