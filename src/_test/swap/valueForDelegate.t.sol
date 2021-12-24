// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

import {User} from '../utils/User.sol';

contract swapTest__valueForDelegate is t, NuggFatherFix {
    uint32 epoch;

    function setUp() public {
        reset();

        epoch = nuggft.epoch();
    }

    function test__swap__valueForDelegate__returnsAValidAmount() public {
        (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(address(mac), epoch);
        emit log_named_uint('mac top', top);
        emit log_named_uint('mac curr', curr);
        assertTrue(should);
        nuggft_call(mac, delegate(address(mac), epoch), top - curr);
    }

    function test__swap__valueForDelegate__returnsAValidAmountRevert() public {
        nuggft_call(mac, delegate(address(mac), epoch), 11 * 10**16);

        // call_delegate(mac, fastAmount(epoch, mac), epoch);
        (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(address(mac), epoch);
        assertTrue(should);

        nuggft_revertCall('S:G', dee, delegate(address(dee), epoch), top - curr - 1);
    }

    function test__swap__valueForDelegate__returnsLotsOfValidAmount() public {
        uint96 last;
        for (uint256 i = 0; i < 5; i++) {
            (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(address(mac), epoch);
            assertTrue(should);
            assertTrue(last < top);
            last = top;
            emit log_named_uint('mac bef', curr);

            nuggft_call(mac, delegate(address(mac), epoch), top - curr);

            (should, top, curr) = nuggft.valueForDelegate(address(mac), epoch);

            emit log_named_uint('mac aft', curr);

            (should, top, curr) = nuggft.valueForDelegate(address(frank), epoch);

            emit log_named_uint('fra bef', curr);

            assertTrue(should);
            assertTrue(last < top);
            last = top;

            nuggft_call(frank, delegate(address(frank), epoch), top - curr);

            (should, top, curr) = nuggft.valueForDelegate(address(frank), epoch);

            emit log_named_uint('fra aft', curr);
        }
    }
}
