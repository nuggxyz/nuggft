//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import '../NuggftV1.test.sol';

abstract contract base is DSTest {
    RiggedNuggft nuggft;

    constructor(RiggedNuggft nuggft_) {
        nuggft = nuggft_;
    }
}
