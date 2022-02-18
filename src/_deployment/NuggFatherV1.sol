// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {NuggftV1} from '../NuggftV1.sol';

import {DotnuggV1} from '../../../dotnugg-v1-core/src/DotnuggV1.sol';

import {IDotnuggV1Safe} from '../interfaces/dotnugg/IDotnuggV1Safe.sol';

contract NuggFatherV1 {
    DotnuggV1 public dotnugg;
    NuggftV1 public nuggft;

    constructor(bytes memory a) {
        dotnugg = new DotnuggV1();

        nuggft = new NuggftV1(address(dotnugg), abi.decode(a, (bytes[])));
    }
}
