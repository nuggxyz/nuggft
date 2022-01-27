//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import '../utils/forge.sol';

import {RiggedNuggft} from '../NuggftV1.test.sol';

abstract contract expectBase is DSTest {
    function __nuggft__ref() internal virtual returns (RiggedNuggft);
}
