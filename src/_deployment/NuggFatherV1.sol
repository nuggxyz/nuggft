// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {NuggftV1} from '../NuggftV1.sol';

import {DotnuggV1} from '../../../dotnugg-v1-core/src/DotnuggV1.sol';

// import {data as nuggs} from '../_data/nuggs.data.sol';

contract NuggFatherV1 {
    DotnuggV1 public immutable dotnugg;

    NuggftV1 public immutable nuggft;

    constructor() {
        dotnugg = DotnuggV1(address(new DotnuggV1()));

        nuggft = new NuggftV1(address(dotnugg));

        for (uint160 i = 0; i < 5; i++) {
            nuggft.trustedMint(i + 1, 0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        }
    }
}

// // import {NuggftV1} from '../NuggftV1.sol';

// import {IDotnuggV1Safe} from '../interfaces/dotnugg/IDotnuggV1Safe.sol';
// import {IDotnuggV1} from '../interfaces/dotnugg/IDotnuggV1.sol';

// contract NuggFatherV1 {
//     IDotnuggV1 public dotnugg;

//     // NuggftV1 public nuggft;

//     constructor(bytes memory a) {
//         // dotnugg = new DotnuggV1();

//         bytes memory dat = dotnugg__bytecode;

//         assembly {
//             let res := create(0, add(0x20, dat), mload(dat))
//             sstore(dotnugg.slot, res)
//         }

//         // nuggft = new NuggftV1(address(dotnugg), abi.decode(a, (bytes[])));
//     }
// }
