// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {NuggFatherFix} from '../fixtures/NuggFather.fix.sol';

contract swapTest__claim is t, NuggFatherFix {
    uint160 tokenId;

    // function setUp() public {
    //     reset();

    //     (tokenId) = scenario_dee_has_swapped_a_token_and_mac_can_claim();
    // }

    // function test__swap__claim__shouldSucceedForDelegators() public {
    //     nuggft_call(mac, claim(address(mac), tokenId));
    //     nuggft_call(dee, claim(address(mac), tokenId));
    // }

    // function test__swap__claim__shouldFailForNonDelegators() public {
    //     nuggft_revertCall('S:8', dee, claim(address(frank), tokenId));
    // }

    // function test__swap__claim__shouldFailForRepeatClaim() public {
    //     nuggft_call(mac, claim(address(mac), tokenId));
    //     nuggft_call(dee, claim(address(mac), tokenId));

    //     nuggft_revertCall('S:8', mac, claim(address(mac), tokenId));
    //     nuggft_revertCall('S:8', dee, claim(address(dee), tokenId));
    // }
}
