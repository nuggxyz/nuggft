// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {EpochCore} from '../../../epoch/EpochCore.sol';

contract EpochCoreTest__calculateSeed is t {
    function test__EpochCore__calculateSeed__a() public {
        hevm.roll(100);

        (uint256 seed, uint256 epoch) = EpochCore.calculateSeed();

        assertEq(seed, 9912418261204039789768554002824411088073917673079298756120843478505709301651);
        assertEq(epoch, 4);
    }
}
