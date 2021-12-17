// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {SafeCastLib} from '../../../libraries/SafeCastLib.sol';

contract SafeCastLibTest__safe192 is t {
    function test__SafeCastLib__safe192__g1() public {
        assertEq(SafeCastLib.safe192(type(uint192).max), type(uint192).max);
    }
}
