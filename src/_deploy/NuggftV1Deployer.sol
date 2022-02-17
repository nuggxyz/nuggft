// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Safe} from '../interfaces/dotnuggv1/IDotnuggV1Safe.sol';
// import {DotnuggV1} from '../interfaces/dotnuggv1/ol';
// import '../interfaces/dotnuggv1/fe.sol';
// import '../interfaces/dotnuggv1/solver.sol';
// import '../interfaces/dotnuggv1/gV1Storage.sol';
// import '../interfaces/dotnuggv1/gV1MiddleOut.sol';
// import '../interfaces/dotnuggv1/gV1Svg.sol';
// import '../interfaces/dotnuggv1/gV1Storage.sol';
// import '../interfaces/dotnuggv1/gV1Storage.sol';
import {NuggftV1} from '../NuggftV1.sol';
import {IDotnuggV1Resolver} from '../interfaces/dotnuggv1/IDotnuggV1Resolver.sol';
import {IDotnuggV1} from '../interfaces/dotnuggv1/IDotnuggV1.sol';

// import {data} from '../_data/a.data.sol';
// import {data as dotnuggdata} from '../_data/dotnugg.data.sol';

contract NuggftV1Deployer {
    IDotnuggV1 dotnuggv1;
    NuggftV1 nuggftv1;

    // IDotnuggV1Safe immutable safe;

    // constructor() {
    //     // dotnuggv1 = new DotnuggV1();

    //     bytes memory dnd = dotnuggdata;
    //     assembly {
    //         let res := create(0, dnd, mload(dnd))
    //         sstore(dotnuggv1.slot, res)
    //     }
    //     nuggftv1 = new NuggftV1(dotnuggv1, abi.decode(data, (bytes[])));
    // }
}
