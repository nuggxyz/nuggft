// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {NuggftV1} from "../NuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract NuggFatherV1Lite {
    DotnuggV1 public immutable dotnugg;

    constructor() {
        dotnugg = new DotnuggV1();
    }
}

contract NuggFatherV1 {
    DotnuggV1 public immutable dotnugg;

    NuggftV1 public immutable nuggft;

    constructor() payable {
        nuggft = new NuggftV1{value: msg.value}();

        dotnugg = DotnuggV1(address(nuggft.dotnuggv1()));
    }

    uint24 index = 1001001;

    function mint(uint24 amount) external payable {
        for (uint24 i = index; i < index + amount; i++) {
            nuggft.mint{value: nuggft.msp()}(uint24(i));

            uint16[] memory f = nuggft.floop(i);

            uint16 itemId3 = uint16(f[4]);

            if (itemId3 != 0) nuggft.sell(i, itemId3, .0069 ether);

            uint16 itemId4 = uint16(f[8]);

            nuggft.sell(i, itemId4, .0069 ether);
        }

        index += amount;

        payable(msg.sender).transfer(address(this).balance);
    }
}

// for (uint24 i = 0; i < 3; i++) {
//     nuggft.trustedMint(1000000 + i + 1, 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
//     nuggft.trustedMint(1000000 + 3 + i + 1, 0x4E503501C5DEDCF0607D1E1272Bb4b3c1204CC71);
// }

// for (uint24 i = 1000000; i < 1000020; i++) {
//     nuggft.trustedMint(i, address(this));

//     uint16[] memory f = nuggft.floop(i);

//     uint16 itemId3 = f[4];

//     if (itemId3 != 0) nuggft.sell(i, itemId3, .0069 ether);

//     uint16 itemId4 = f[8];

//     nuggft.sell(i, itemId4, .0069 ether);

//     // uint16 itemId3 = f[8];

//     // if (itemId3 != itemId && itemId3 != itemId2 && itemId4 != itemId3) {
//     //     nuggft.sell(i, itemId3, .005 ether);
//     // }
// }

// payable(msg.sender).transfer(address(this).balance);
