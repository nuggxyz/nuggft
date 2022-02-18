// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

// import {NuggftV1} from '../NuggftV1.sol';

import {IDotnuggV1Safe} from '../interfaces/dotnugg/IDotnuggV1Safe.sol';
import {IDotnuggV1} from '../interfaces/dotnugg/IDotnuggV1.sol';

import {data as dotnugg__bytecode} from '../_data/dotnugg.data.sol';

contract NuggFatherV1 {
    IDotnuggV1 public dotnugg;

    // NuggftV1 public nuggft;

    constructor(bytes memory a) {
        // dotnugg = new DotnuggV1();

        bytes memory dat = dotnugg__bytecode;

        assembly {
            let res := create(0, add(0x20, dat), mload(dat))
            sstore(dotnugg.slot, res)
        }

        // nuggft = new NuggftV1(address(dotnugg), abi.decode(a, (bytes[])));
    }
}
