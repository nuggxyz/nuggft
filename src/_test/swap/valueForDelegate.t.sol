// SPDX-License-Identifier: UNLICENSED

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
        (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(epoch, address(mac));
        emit log_named_uint('mac top', top);
        emit log_named_uint('mac curr', curr);
        assertTrue(should);
        call_delegate(mac, top - curr, epoch);
    }

    function test__swap__valueForDelegate__returnsAValidAmountRevert() public {
        call_delegate(mac, 11 * 10**16, epoch);

        // call_delegate(mac, fastAmount(epoch, mac), epoch);
        (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(epoch, address(mac));
        assertTrue(should);

        revertCall_delegate(dee, top - curr - 1, 'E:1', epoch);
    }

    function test__swap__valueForDelegate__returnsLotsOfValidAmount() public {
        uint96 last;
        for (uint256 i = 0; i < 5; i++) {
            (bool should, uint96 top, uint96 curr) = nuggft.valueForDelegate(epoch, address(mac));
            assertTrue(should);
            assertTrue(last < top);
            last = top;
            emit log_named_uint('mac bef', curr);

            call_delegate(mac, top - curr, epoch);

            (should, top, curr) = nuggft.valueForDelegate(epoch, address(mac));

            emit log_named_uint('mac aft', curr);

            (should, top, curr) = nuggft.valueForDelegate(epoch, address(frank));

            emit log_named_uint('fra bef', curr);

            assertTrue(should);
            assertTrue(last < top);
            last = top;

            call_delegate(frank, top - curr, epoch);

            (should, top, curr) = nuggft.valueForDelegate(epoch, address(frank));

            emit log_named_uint('fra aft', curr);
        }
    }
}
