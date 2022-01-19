// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import './error.sol';
import './logger.sol';
import './store.sol';
import './DSTest.sol';
import './gas.sol';
import './vm.sol';

abstract contract ForgeTest is DSTest {
    modifier trackGas() {
        uint256 a;
        assembly {
            a := gas()
        }

        _;
        assembly {
            a := sub(a, gas())
        }

        console.log('gas used: ', a);
    }
    modifier prank(address user, uint256 value) {
        forge.vm.deal(user, value);
        forge.vm.startPrank(user);
        _;
        forge.vm.stopPrank();
    }
}
