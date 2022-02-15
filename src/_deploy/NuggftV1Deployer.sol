// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Safe} from '@nuggxyz/dotnugg-v1-core/interfaces/IDotnuggV1Safe.sol';
import {DotnuggV1} from '@nuggxyz/dotnugg-v1-core/DotnuggV1.sol';
// import '@nuggxyz/dotnugg-v1-core/DotnuggV1Safe.sol';
// import '@nuggxyz/dotnugg-v1-core/DotnuggV1Resolver.sol';
// import '@nuggxyz/dotnugg-v1-core/core/DotnuggV1Storage.sol';
// import '@nuggxyz/dotnugg-v1-core/core/DotnuggV1MiddleOut.sol';
// import '@nuggxyz/dotnugg-v1-core/core/DotnuggV1Svg.sol';
// import '@nuggxyz/dotnugg-v1-core/core/DotnuggV1Storage.sol';
// import '@nuggxyz/dotnugg-v1-core/core/DotnuggV1Storage.sol';

import {IDotnuggV1Resolver} from '@nuggxyz/dotnugg-v1-core/interfaces/IDotnuggV1Resolver.sol';

import {data} from '../_data/a.data.sol';

contract NuggftV1Deployer {
    DotnuggV1 immutable dotnuggv1;
    IDotnuggV1Safe immutable safe;

    constructor() {
        dotnuggv1 = new DotnuggV1();

        safe = dotnuggv1.register();

        safe.write(abi.decode(data, (bytes[])));
    }
}
