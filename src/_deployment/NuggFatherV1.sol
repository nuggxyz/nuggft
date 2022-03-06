// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {NuggftV1} from "../NuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract NuggFatherV1 {
    DotnuggV1 public immutable dotnugg;

    NuggftV1 public immutable nuggft;

    constructor() {
        dotnugg = DotnuggV1(address(new DotnuggV1()));

        nuggft = new NuggftV1(address(dotnugg));

        for (uint160 i = 0; i < 5; i++) {
            nuggft.trustedMint(i + 1, 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
            nuggft.trustedMint(5 + i + 1, 0x4E503501C5DEDCF0607D1E1272Bb4b3c1204CC71);
        }

        for (uint160 i = 2420; i < 2450; i++) {
            nuggft.mint(i);

            bytes2[] memory f = nuggft.floop(i);

            uint16 itemId = uint16(f[2]);

            nuggft.sell(i, itemId, 696969 gwei);

            itemId = uint16(f[3]);

            nuggft.sell(i, itemId, 696969 gwei);

            itemId = uint16(f[8]);

            nuggft.sell(i, itemId, 696969 gwei);
        }
    }
}
