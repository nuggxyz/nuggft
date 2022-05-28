// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";
import {DotnuggV1Lib} from "../../../libraries/DotnuggV1Lib.sol";

abstract contract logic__DotnuggV1Lib is NuggftV1Test {
    function test__logic__DotnuggV1Lib__ratityX128__2() public {
        expect.mint().from(users.frank).exec{value: 1 ether}(mintable(100));
        ds.inject.log(DotnuggV1Lib.size(DotnuggV1Lib.location(address(dotnugg), 0)));
        // ds.inject.logBytes32(bytes32(DotnuggV1Lib.rarityX128(address( dotnugg), nuggft.proof(600))));
    }

    function test__logic__DotnuggV1Lib__ratityX128() public {
        ds.inject.logBytes32(bytes32(bytes2(DotnuggV1Lib.rarity(address(dotnugg), 0, 2))));
    }
}
