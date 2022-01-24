// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../../NuggftV1.test.sol';

import {NuggftV1Epoch} from '../../../core/NuggftV1Epoch.sol';

contract revert__NuggftV1Epoch is NuggftV1Test, NuggftV1Epoch {
    function setUp() public {
        reset();
        forge.vm.roll(15000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [E:0] - calculateSeed - "block hash does not exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Epoch__calculateSeed__0xE0__failNextEpoch() public {
        uint24 epoch = nuggft.epoch();

        forge.vm.expectRevert(hex'0E');
        nuggft.external__calculateSeed(epoch + 1);
    }

    function test__revert__NuggftV1Epoch__calculateSeed__0xE0__succeedCurrentBlock() public view {
        nuggft.external__calculateSeed();
    }
}
