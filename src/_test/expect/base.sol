//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../utils/forge.sol";

import "../NuggftV1.test.sol";
import "../../interfaces/nuggftv1/INuggftV1.sol";

abstract contract base is INuggftV1Events {
    RiggedNuggft nuggft;

    constructor() {
        nuggft = RiggedNuggft(global.getAddressSafe("RiggedNuggft"));
    }
}
