// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';
import {NuggftV1Proof} from '../../../core/NuggftV1Proof.sol';
import {fragments} from './fragments.t.sol';

contract system__NuggftV1Epoch is NuggftV1Test {
    function setUp() public {
        reset__fork();
    }

    function test__system__epoch__minting() public {
        // for (uint256 i = 0; i < 250; i++) {
        //     uint24 e = nuggft.epoch();
        //     nuggft.external__calculateSeed(e - 1);
        //     nuggft.external__calculateSeed(e);
        //     nuggft.external__calculateSeed(e + 1);
        //     forge.vm.roll(block.number + 1);
        //     // if (nuggft.start(nuggft.epoch() + 1) - 2 == block.number) {
        //     // }
        // }
    }
}
