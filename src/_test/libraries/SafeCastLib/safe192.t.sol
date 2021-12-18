// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../../utils/DSTestPlus.sol';

import {SafeCastLib} from '../../../libraries/SafeCastLib.sol';

contract SafeCastLibTest__safe96 is t {
    function test__SafeCastLib__safe96__g1() public {
        assertEq(SafeCastLib.safe96(type(uint96).max), type(uint96).max);
    }
}
