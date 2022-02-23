// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import '../../NuggftV1.test.sol';
import {DotnuggV1Lib} from '../../../libraries/DotnuggV1Lib.sol';

abstract contract logic__DotnuggV1Lib is NuggftV1Test {
    function test__logic__DotnuggV1Lib__ratityX128__2() public {
        expect.mint().from(users.frank).exec{value: 1 ether}(600);
        ds.inject.log(DotnuggV1Lib.size(DotnuggV1Lib.location(address(processor), 0)));
        // ds.inject.logBytes32(bytes32(DotnuggV1Lib.rarityX128(address(processor), nuggft.proofOf(600))));
    }

    function test__logic__DotnuggV1Lib__ratityX128() public {
        ds.inject.logBytes32(bytes32(DotnuggV1Lib.rarityX128(address(processor), 0, 2)));
    }
}
