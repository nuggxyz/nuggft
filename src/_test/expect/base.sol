//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import '../utils/forge.sol';

import '../NuggftV1.test.sol';

abstract contract base {
    RiggedNuggft nuggft;

    constructor() {
        nuggft = RiggedNuggft(global.getAddressSafe('RiggedNuggft'));
    }
}
