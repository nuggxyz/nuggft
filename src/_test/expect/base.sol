//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "../utils/forge.sol";
import "../RiggedNuggftV1.sol";

import "../NuggftV1.test.sol";
import "../../interfaces/nuggftv1/INuggftV1.sol";
import {xNuggftV1} from "../../xNuggftV1.sol";

abstract contract base is INuggftV1Events {
    RiggedNuggftV1 nuggft;
    xNuggftV1 internal xnuggft;

    constructor() {
        nuggft = RiggedNuggftV1(global.getAddressSafe("RiggedNuggft"));
        xnuggft = nuggft.xnuggftv1();
    }
}
