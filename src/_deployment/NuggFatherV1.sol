// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import {NuggftV1} from "../NuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract NuggFatherV1 {
    DotnuggV1 public immutable dotnugg;

    NuggftV1 public immutable nuggft;

    constructor() {
        dotnugg = new DotnuggV1();

        nuggft = new NuggftV1(address(dotnugg));

        for (uint160 i = 0; i < 3; i++) {
            nuggft.trustedMint(i + 1, 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
            nuggft.trustedMint(3 + i + 1, 0x4E503501C5DEDCF0607D1E1272Bb4b3c1204CC71);
        }

        for (uint160 i = 150; i < 160; i++) {
            nuggft.trustedMint(i, address(this));

            bytes2[] memory f = nuggft.floop(i);

            uint16 itemId = uint16(f[2]);

            nuggft.sell(i, itemId, 696969 gwei);

            uint16 itemId2 = uint16(f[3]);

            nuggft.sell(i, itemId2, 696969 gwei);

            uint16 itemId3 = uint16(f[8]);

            if (itemId3 != itemId && itemId3 != itemId2) {
                nuggft.sell(i, itemId3, 696969 gwei);
            }
        }
    }

    uint160 index = 1000;

    function mint(uint160 amount) external payable {
        for (uint160 i = index; i < index + amount && i < 3000; i++) {
            nuggft.mint{value: nuggft.msp()}(uint160(i));
        }

        index += amount;

        payable(msg.sender).transfer(address(this).balance);
    }
}
