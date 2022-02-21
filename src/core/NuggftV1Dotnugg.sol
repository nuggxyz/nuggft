// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {IDotnuggV1} from '../interfaces/dotnugg/IDotnuggV1.sol';

import {NuggftV1Token} from './NuggftV1Token.sol';

import {NuggftV1Trust} from './NuggftV1Trust.sol';

/// @custom:testing test each function
abstract contract NuggftV1Dotnugg is NuggftV1Token, NuggftV1Trust {
    IDotnuggV1 public immutable dotnuggV1;

    constructor(address dotnugg) {
        dotnuggV1 = IDotnuggV1(dotnugg);
    }
}
