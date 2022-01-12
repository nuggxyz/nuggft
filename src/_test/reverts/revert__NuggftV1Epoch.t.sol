// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';

import {NuggftV1Epoch} from '../../core/NuggftV1Epoch.sol';

contract revert__NuggftV1Epoch is NuggftV1Test, NuggftV1Epoch {
    using UserTarget for address;

    function setUp() public {
        reset();
        fvm.roll(15000);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        [E:0] - calculateSeed - "block hash does not exist"
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function test__revert__NuggftV1Epoch__calculateSeed__E_0__failNextEpoch() public {
        uint24 epoch = nuggft.epoch();

        fvm.expectRevert('E:0');
        nuggft.external__calculateSeed(epoch + 1);
    }

    function test__revert__NuggftV1Epoch__calculateSeed__E_0__succeedCurrentBlock() public view {
        nuggft.external__calculateSeed();
    }
}
