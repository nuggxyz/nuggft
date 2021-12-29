// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../fixtures/NuggFather.fix.sol';

contract NuggftV1SwapTest is NuggFatherFix {
    uint32 epoch;
    uint32 ogepoch;

    using UserTarget for address;

    function setUp() public {
        reset();

        ogepoch = nuggft.epoch();

        _nuggft.shouldPass(frank, delegate(address(frank), ogepoch), 1 ether);

        for (uint256 i = 0; i < 100; i) {
            _nuggft.shouldPass(frank, mint(i), nuggft.minSharePrice());
        }

        fvm.roll(1000);

        epoch = nuggft.epoch();
    }

    function test__NuggftV1Swap__delegate() public {
        _nuggft.shouldPass(frank, delegate(address(frank), epoch), 2 ether);
    }

    function test__NuggftV1Swap__claim() public {
        _nuggft.shouldPass(frank, claim(address(frank), ogepoch));
    }

    function test__NuggftV1Swap__delegateItem() public {
        _nuggft.shouldPass(frank, claim(address(frank), ogepoch));
    }
}
