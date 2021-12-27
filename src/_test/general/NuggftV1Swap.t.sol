// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract NuggftV1SwapTest is NuggFatherFix {
    uint32 epoch;
    uint32 ogepoch;

    function setUp() public {
        reset();

        ogepoch = nuggft.epoch();

        nuggft_call(frank, delegate(address(frank), ogepoch), 1 ether);

        fvm.roll(1000);

        epoch = nuggft.epoch();
    }

    function test__NuggftV1Swap__delegate() public {
        nuggft_call(frank, delegate(address(frank), epoch), 2 ether);
    }

    function test__NuggftV1Swap__claim() public {
        nuggft_call(frank, claim(address(frank), ogepoch));
    }
}
